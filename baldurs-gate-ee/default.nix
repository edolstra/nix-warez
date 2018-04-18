with import <nixpkgs> { system = "i686-linux"; };

let

  version = "2.5.0.9";

  url = https://www.gog.com/game/baldurs_gate_enhanced_edition;

  /* Put the game data in a fixed-output derivation so we don't need
     to rebuild it when the wrapper script changes. */
  data =
    runCommand "baldurs-gate-ee-${version}-data"
      {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "1lndfq4kybxhn47rpagbm6qirln6jfylc6qynknsipriimmz24ha";

        buildInputs = [ unzip ];

        src = requireFile {
          name = "gog_baldur_s_gate_enhanced_edition_${version}.sh";
          sha256 = "d12418554ce1404acbb8afcc5153fe8007b228127c40e2c48c8877233fce541e";
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

in

stdenv.mkDerivation rec {
  name = "baldurs-gate-ee-${version}";

  buildCommand =
    ''
      lib=$out/lib/baldurs-gate-ee

      mkdir -p $out/bin $lib

      ln -s ${json_c}/lib/libjson-c.so.2 $lib/libjson.so.0

      cat > $out/bin/BaldursGate <<EOF
      cd ${data}/data/noarch/game
      LD_LIBRARY_PATH=$lib:${libPath}:\$LD_LIBRARY_PATH:${mesa}/lib exec ${glibc}/lib/ld-linux.so.2 ./BaldursGate
      EOF

      chmod +x $out/bin/BaldursGate
    '';

  meta = {
    description = "Baldur's Gate: Enhanced Edition, the classic BioWare RPG";
    homepage = url;
    license = lib.licenses.unfree;
  };
}
