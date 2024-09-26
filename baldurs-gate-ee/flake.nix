rec {
  description = "Baldur's Gate: Enhanced Edition, the classic BioWare RPG";

  inputs.nixpkgs.url = "nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = {

      baldurs-gate-ee =
        with import nixpkgs { config.permittedInsecurePackages = [ "openssl-1.0.2u" ]; system = "x86_64-linux"; };

        let
          version = "2.5.23121";

          url = "https://www.gog.com/game/baldurs_gate_enhanced_edition";

          /* Put the game data in a fixed-output derivation so we don't need
             to rebuild it when the wrapper script changes. */
          data =
            runCommand "baldurs-gate-ee-${version}-data"
              {
                outputHashMode = "recursive";
                outputHash = "sha256-t30A1Y9Ee3lsfmY8K3BzJJ4wX5a5yEHQDlR5j0LYiT4=";

                buildInputs = [ unzip ];

                src = requireFile {
                  name = "baldur_s_gate_enhanced_edition_en_${builtins.replaceStrings ["."] ["_"] version}.sh";
                  sha256 = "80ad443563ce65382f1c7c9b8f4b488041449edd7f3bce017ff3eb7cd8250d65";
                  inherit url;
                };
              }
              ''
                # "|| true" is needed to ignore the warning about the
                # extraneous data at the start.
                unzip "$src" -d $out || true
              '';

          libPath = lib.makeLibraryPath
            [ openal
              gcc.cc
              openssl_1_0_2
              expat
              xorg.libX11
            ];

        in stdenv.mkDerivation rec {
          name = "baldurs-gate-ee-${version}";

          buildCommand =
            ''
              lib=$out/lib/baldurs-gate-ee

              mkdir -p $out/bin $lib

              ln -s ${json_c}/lib/libjson-c.so.? $lib/libjson.so.0

              cat > $out/bin/BaldursGate <<EOF
              cd ${data}/data/noarch/game
              LD_LIBRARY_PATH=$lib:${libPath}:\$LD_LIBRARY_PATH:${libGL}/lib exec ${glibc}/lib/ld-linux-x86-64.so.2 ./BaldursGate64
              EOF

              chmod +x $out/bin/BaldursGate
            '';

          meta = {
            inherit description;
            homepage = url;
            #license = lib.licenses.unfree;
          };
        };

    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.baldurs-gate-ee;

    defaultApp.x86_64-linux = {
      type = "app";
      program = "${self.packages.x86_64-linux.baldurs-gate-ee}/bin/BaldursGate";
    };

  };
}
