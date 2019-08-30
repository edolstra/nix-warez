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
  epoch = 201909;

  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.uri = "nixpkgs/release-19.03";

  outputs = { self, nixpkgs }: let pkgs = nixpkgs.legacyPackages; in rec {

    packages = {

      blender_2_79 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.79-20190523-054dbb833e15";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2;
          hash = "sha256-/qbRx4KKiJBka84M4iXB8z3PKzqBIuWG5Zihyf//QTU=";
        };
      };

      blender_2_81 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.81-20190803-5e5cf9ea9f7b";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.81-5e5cf9ea9f7b-linux-glibc217-x86_64.tar.bz2;
          hash = "sha256-jUHfAmi3lCxPxrusnahtufbah9zVV+glNbSqQxA4T0Q=";
        };
      };

    };

    defaultPackage = packages.blender_2_81;

    apps = {

      blender_2_79 = {
        type = "app";
        program = "${packages.blender_2_79}/bin/blender";
      };

      blender_2_81 = {
        type = "app";
        program = "${packages.blender_2_81}/bin/blender";
      };

    };

    defaultApp = apps.blender_2_81;

    checks = {
      blender_2_79 = mkTest { inherit pkgs; blender = packages.blender_2_79; };
      blender_2_81 = mkTest { inherit pkgs; blender = packages.blender_2_81; };
    };

  };
}
