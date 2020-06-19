{
  inputs.nixpkgs.url = "nixpkgs/nixos-20.03";

  inputs.comic-dl = {
    type = "github";
    owner = "Xonshiz";
    repo = "comic-dl";
    flake = false;
  };

  outputs = { self, nixpkgs, comic-dl } @ inputs:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlay ];
      };

    in {

      overlay = final: prev: {

        comic-dl = with final.python3.pkgs; buildPythonApplication rec {
          pname = "comic-dl";
          version = "${nixpkgs.lib.substring 0 8 inputs.comic-dl.lastModifiedDate}";

          src = inputs.comic-dl;

          patches = [ ./install.patch ];

          postInstall = ''
            mkdir -p $out/bin
            cp $out/lib/python3.7/site-packages/comic_dl/__main__.py $out/bin/comic-dl
            chmod +x $out/bin/comic-dl
          '';

          postFixup = ''
            wrapProgram $out/bin/comic-dl --prefix PYTHONPATH : $out/lib/python3.7/site-packages/comic_dl
          '';

          pythonPath = [ more-itertools selenium cloudscraper pyparsing requests requests_toolbelt bs4 brotli tqdm final.img2pdf pillow ];

          doCheck = false;
        };

        python3 = prev.python3.override {
          packageOverrides = final: prev: {

            cloudscraper = with final; buildPythonPackage rec {
              pname = "cloudscraper";
              version = "1.2.40";

              src = fetchPypi {
                inherit pname version;
                hash = "sha256-5xH4pBOT2XVReNYpD8y/yE8LnbILveq6vPjNkjLzgM0=";
              };

              buildInputs = [ requests requests_toolbelt brotli pyparsing ];

              doCheck = false;
            };

            bs4 = with final; buildPythonPackage rec {
              pname = "bs4";
              version = "0.0.1";

              src = fetchPypi {
                inherit pname version;
                sha256 = "0fnxhql23ql6q5n64xjknx3sc3fm4vgpbw0z99p0qp6cswgymv1n";
              };

              propagatedBuildInputs = [ beautifulsoup4 ];
            };

            pyparsing = with final; buildPythonPackage rec {
              pname = "pyparsing";
              version = "2.4.7";

              src = fetchPypi {
                inherit pname version;
                hash = "sha256-wgPsh4O/dxoVWyByebm8y43qAtjwyeX46tUHvDJG7ME=";
              };
            };
          };

        };

      };

      defaultPackage.x86_64-linux = pkgs.comic-dl;

  };
}
