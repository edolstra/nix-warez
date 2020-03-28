{
  edition = 201909;

  inputs.nixpkgs.url = "nixpkgs/release-19.09";

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

      overlay = final: prev: with final; with python3Packages; {

        comic-dl = buildPythonApplication rec {
          pname = "comic-dl";
          version = "${lib.substring 0 8 inputs.comic-dl.lastModified}";

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

          pythonPath = [ more-itertools selenium cloudscraper requests requests_toolbelt bs4 brotli tqdm img2pdf pillow ];

          doCheck = false;
        };

        bs4 = buildPythonPackage rec {
          pname = "bs4";
          version = "0.0.1";

          src = fetchPypi {
            inherit pname version;
            sha256 = "0fnxhql23ql6q5n64xjknx3sc3fm4vgpbw0z99p0qp6cswgymv1n";
          };

          propagatedBuildInputs = [ beautifulsoup4 ];
        };

        cloudscraper = buildPythonPackage rec {
          pname = "cloudscraper";
          version = "1.2.30";

          src = fetchPypi {
            inherit pname version;
            sha256 = "1l27z5wj7qazpj37dnmw37qs6b2a2rg2k79h5hirwqj0q4r5lw8n";
          };

          buildInputs = [ requests requests_toolbelt brotli ];

          doCheck = false;
        };

      };

      defaultPackage.x86_64-linux = pkgs.comic-dl;

  };
}
