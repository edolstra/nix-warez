let

  mkBlender = { pkgs, name, src }:
    with pkgs;

    stdenv.mkDerivation rec {
      inherit name src;

      buildInputs = [ makeWrapper ];

      preUnpack =
        ''
          mkdir -p $out/libexec
          cd $out/libexec
        '';

      installPhase =
        ''
          cd $out/libexec
          mv blender-* blender

          mkdir $out/bin

          makeWrapper $out/libexec/blender/blender $out/bin/blender \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXfixes xorg.libXrender libGLU libglvnd numactl SDL2 libdrm ]}

          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            blender/blender
        '';
    };

  mkTest = { pkgs, blender }:
    with pkgs;
    runCommand "blender-test" { buildInputs = [ blender ]; }
      ''
        blender --version
        touch $out
      '';

in

{
  name = "blender-bin";

  epoch = 201906;

  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs = [ "nixpkgs" ];

  outputs = inputs: let pkgs = inputs.nixpkgs.outputs.legacyPackages; in rec {

    packages = {

      blender_2_79 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.79-20190523-054dbb833e15";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2;
          hash = "sha256-/qbRx4KKiJBka84M4iXB8z3PKzqBIuWG5Zihyf//QTU=";
        };
      };

      blender_2_80 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.80-20190609-030c7df19da9";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.80-030c7df19da9-linux-glibc224-x86_64.tar.bz2;
          hash = "sha256-awi5URUcvJNuJdC9esrIiQYAgfFRKvcsrRiHm7A5VW8=";
        };
      };

    };

    defaultPackage = packages.blender_2_80;

    apps = {

      blender_2_79 = {
        type = "app";
        program = "${packages.blender_2_79}/bin/blender";
      };

      blender_2_80 = {
        type = "app";
        program = "${packages.blender_2_80}/bin/blender";
      };

    };

    defaultApp = apps.blender_2_80;

    checks = {
      blender_2_79 = mkTest { inherit pkgs; blender = packages.blender_2_79; };
      blender_2_80 = mkTest { inherit pkgs; blender = packages.blender_2_80; };
    };

  };
}

