rec {
  name = "baldurs-gate-ee";

  epoch = 201906;

  description = "Baldur's Gate: Enhanced Edition, the classic BioWare RPG";

  inputs = [ "nixpkgs" ];

  outputs = inputs: rec {

    packages = with import inputs.nixpkgs { system = "i686-linux"; }; {

      baldurs-gate-ee =
        let
          version = "2.5.23121";

          url = https://www.gog.com/game/baldurs_gate_enhanced_edition;

          /* Put the game data in a fixed-output derivation so we don't need
             to rebuild it when the wrapper script changes. */
          data =
            runCommand "baldurs-gate-ee-${version}-data"
              {
                outputHashMode = "recursive";
                outputHash = "sha256:0gl9v118yyal1v843j5rjrgk17i4fdq2ng36grn7jys4izah0zdp";

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
              openssl
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
              LD_LIBRARY_PATH=$lib:${libPath}:\$LD_LIBRARY_PATH:${libGL}/lib exec ${glibc}/lib/ld-linux.so.2 ./BaldursGate
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

    defaultPackage = packages.baldurs-gate-ee;

    defaultApp = {
      type = "app";
      program = "${packages.baldurs-gate-ee}/bin/BaldursGate";
    };

  };
}
