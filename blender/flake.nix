{
  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.url = "nixpkgs/nixos-20.03";

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
                --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath [ xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXfixes xorg.libXrender libGLU libglvnd numactl SDL2 libdrm ocl-icd ]}

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                blender/blender

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
                $out/libexec/blender/*/python/bin/python3*
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
          name = "blender-bin-2.82a";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz;
            hash = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
          };
        };

        blender_2_83 = mkBlender {
          name = "blender-bin-2.83.5";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.83/blender-2.83.5-linux64.tar.xz;
            hash = "sha256-sSaZPtLeDh51HPVcKfK7RdAAWJ4iiJ4EnJ0L+yOGuiI=";
          };
        };

        blender_2_90 = mkBlender {
          name = "blender-bin-2.90.0";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.0-linux64.tar.xz;
            hash = "sha256-0Mkhj6T8mBIE09GHw1tRaLTfTqceLnT7Yb4VQLk1qDw=";
          };
        };

      };

      packages.x86_64-linux = {
        inherit (pkgs) blender_2_79 blender_2_81 blender_2_82 blender_2_83 blender_2_90;
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.blender_2_90;

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

        x86_64-linux.blender_2_83 = {
          type = "app";
          program = "${self.packages.x86_64-linux.blender_2_83}/bin/blender";
        };

        x86_64-linux.blender_2_90 = {
          type = "app";
          program = "${self.packages.x86_64-linux.blender_2_90}/bin/blender";
        };

      };

      defaultApp.x86_64-linux = self.apps.x86_64-linux.blender_2_90;

      checks.x86_64-linux = {
        blender_2_79 = mkTest { blender = self.packages.x86_64-linux.blender_2_79; };
        blender_2_81 = mkTest { blender = self.packages.x86_64-linux.blender_2_81; };
        blender_2_82 = mkTest { blender = self.packages.x86_64-linux.blender_2_82; };
        blender_2_83 = mkTest { blender = self.packages.x86_64-linux.blender_2_83; };
        blender_2_90 = mkTest { blender = self.packages.x86_64-linux.blender_2_90; };
      };

    };
}
