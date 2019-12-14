{
  edition = 201909;

  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.uri = "nixpkgs/release-19.09";

  outputs = { self, nixpkgs }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlay ];
      };

      mkBlender = { name, src }:
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

      mkTest = { blender }:
        pkgs.runCommand "blender-test" { buildInputs = [ blender ]; }
          ''
            blender --version
            touch $out
          '';

    in {

      overlay = final: prev: {

        blender_2_79 = mkBlender {
          name = "blender-bin-2.79-20190523-054dbb833e15";
          src = import <nix/fetchurl.nix> {
            url = https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2;
            hash = "sha256-/qbRx4KKiJBka84M4iXB8z3PKzqBIuWG5Zihyf//QTU=";
          };
        };

        blender_2_81 = mkBlender {
          name = "blender-bin-2.81a";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2;
            hash = "sha256-CNcYUF0esdJh77qWsHhyIKdtNXzluUrKEI/J4MM51sY=";
          };
        };

        blender_2_82 = mkBlender {
          name = "blender-bin-2.82-20191214-c6ba94133934";
          src = import <nix/fetchurl.nix> {
            url = https://builder.blender.org/download/blender-2.82-c6ba94133934-linux-glibc217-x86_64.tar.xz;
            hash = "sha256-+lmotJfxW/R26jmENEufxFtEaPxEhYHh5Xub5uIReS4=";
          };
        };

      };

      packages.x86_64-linux = {
        inherit (pkgs) blender_2_79 blender_2_81 blender_2_82;
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.blender_2_81;

      apps = {

        x86_64-linux.blender_2_79 = {
          type = "app";
          program = "${self.packages.x86_64-linux.blender_2_79}/bin/blender";
        };

        x86_64-linux.blender_2_81 = {
          type = "app";
          program = "${self.packages.x86_64-linux.blender_2_81}/bin/blender";
        };

        x86_64-linux.blender_2_82 = {
          type = "app";
          program = "${self.packages.x86_64-linux.blender_2_82}/bin/blender";
        };

      };

      defaultApp.x86_64-linux = self.apps.x86_64-linux.blender_2_81;

      checks.x86_64-linux = {
        blender_2_79 = mkTest { blender = self.packages.x86_64-linux.blender_2_79; };
        blender_2_81 = mkTest { blender = self.packages.x86_64-linux.blender_2_81; };
        blender_2_82 = mkTest { blender = self.packages.x86_64-linux.blender_2_82; };
      };

    };
}
