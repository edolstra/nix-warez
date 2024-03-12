{
  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      mkBlender = { pname, version, src }:
        with pkgs;

        let
          libs =
            [ wayland libdecor xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXfixes xorg.libXrender libxkbcommon libGLU libglvnd numactl SDL2 libdrm ocl-icd stdenv.cc.cc.lib openal ]
            ++ lib.optionals (lib.versionAtLeast version "3.5") [ xorg.libSM xorg.libICE zlib ];
        in

        stdenv.mkDerivation rec {
          inherit pname version src;

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

              mkdir -p $out/share/applications
              mv ./blender/blender.desktop $out/share/applications/blender.desktop

              mkdir $out/bin

              makeWrapper $out/libexec/blender/blender $out/bin/blender \
                --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath libs}

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                blender/blender

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
                $out/libexec/blender/*/python/bin/python3*
            '';

          meta.mainProgram = "blender";
        };

      mkTest = { blender }:
        pkgs.runCommand "blender-test" { buildInputs = [ blender ]; }
          ''
            blender --version
            touch $out
          '';

    in {

      overlays.default = final: prev: {

        blender_2_79 = mkBlender {
          pname = "blender-bin";
          version = "2.79-20190523-054dbb833e15";
          src = import <nix/fetchurl.nix> {
            url = https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2;
            hash = "sha256-/qbRx4KKiJBka84M4iXB8z3PKzqBIuWG5Zihyf//QTU=";
          };
        };

        blender_2_81 = mkBlender {
          pname = "blender-bin";
          version = "2.81a";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2;
            hash = "sha256-CNcYUF0esdJh77qWsHhyIKdtNXzluUrKEI/J4MM51sY=";
          };
        };

        blender_2_82 = mkBlender {
          pname = "blender-bin";
          version = "2.82a";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz;
            hash = "sha256-+0ACWBIlJcUaWJcZkZfnQBBJT3HyshIsTdEiMk5u3r4=";
          };
        };

        blender_2_83 = mkBlender {
          pname = "blender-bin";
          version = "2.83.20";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.83/blender-2.83.20-linux-x64.tar.xz;
            hash = "sha256-KuPyb39J+TUrcPUFuPNj0MtRshS4ZmHZTuTpxYjEFPg=";
          };
        };

        blender_2_90 = mkBlender {
          pname = "blender-bin";
          version = "2.90.1";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz;
            hash = "sha256-BUZoxGo+VpIfKDcJ9Ro194YHhhgwAc8uqb4ySdE6xmc=";
          };
        };

        blender_2_91 = mkBlender {
          pname = "blender-bin";
          version = "2.91.2";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz;
            hash = "sha256-jx4eiFJ1DhA4V5M2x0YcGlSS2pc84Yjh5crpmy95aiM=";
          };
        };

        blender_2_92 = mkBlender {
          pname = "blender-bin";
          version = "2.92.0";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz;
            hash = "sha256-LNF61unWwkGsFLhK1ucrUHruyXnaPZJrGhRuiODrPrQ=";
          };
        };

        blender_2_93 = mkBlender {
          pname = "blender-bin";
          version = "2.93.18";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.18-linux-x64.tar.xz;
            hash = "sha256-+H9z8n0unluHbqpXr0SQIGf0wzHR4c30ACM6ZNocNns=";
          };
        };

        blender_3_0 = mkBlender {
          pname = "blender-bin";
          version = "3.0.1";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.0/blender-3.0.1-linux-x64.tar.xz;
            hash = "sha256-TxeqPRDtbhPmp1R58aUG9YmYuMAHgSoIhtklTJU+KuU=";
          };
        };

        blender_3_1 = mkBlender {
          pname = "blender-bin";
          version = "3.1.2";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.1/blender-3.1.2-linux-x64.tar.xz;
            hash = "sha256-wdNFslxvg3CLJoHTVNcKPmAjwEu3PMeUM2bAwZ5UKVg=";
          };
        };

        blender_3_2 = mkBlender {
          pname = "blender-bin";
          version = "3.2.2";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.2/blender-3.2.2-linux-x64.tar.xz;
            hash = "sha256-FyZWAVfZDPKqrrbSXe0Xg9Zr/wQ4FM2VuQ/Arx2eAYs=";
          };
        };

        blender_3_3 = mkBlender {
          pname = "blender-bin";
          version = "3.3.16";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.3/blender-3.3.16-linux-x64.tar.xz;
            hash = "sha256-KNNjROty3Y6gOXm6C8ylaGzUqd9L4bSogG9wEJ9miMY=";
          };
        };

        blender_3_4 = mkBlender {
          pname = "blender-bin";
          version = "3.4.1";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.4/blender-3.4.1-linux-x64.tar.xz;
            hash = "sha256-FJf4P5Ppu73nRUIseV7RD+FfkvViK0Qhdo8Un753aYE=";
          };
        };

        blender_3_5 = mkBlender {
          pname = "blender-bin";
          version = "3.5.1";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.5/blender-3.5.1-linux-x64.tar.xz;
            hash = "sha256-2Crn72DqsgsVSCbE8htyrgAerJNWRs0plMXUpRNvfxw=";
          };
        };

        blender_3_6 = mkBlender {
          pname = "blender-bin";
          version = "3.6.9";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender3.6/blender-3.6.9-linux-x64.tar.xz;
            hash = "sha256-KxBH9Kf4Jr4cHo98BVV4xpeugMYYoDUH3aZRg+xmu5w=";
          };
        };

        blender_4_0 = mkBlender {
          pname = "blender-bin";
          version = "4.0.2";
          src = import <nix/fetchurl.nix> {
            url = https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.0/blender-4.0.2-linux-x64.tar.xz;
            hash = "sha256-VYOlWIc22ohYxSLvF//11zvlnEem/pGtKcbzJj4iCGo=";
          };
        };
      };

      lib.mkBlender = mkBlender;

      packages.x86_64-linux = rec {
        inherit (pkgs)
          blender_2_79
          blender_2_81
          blender_2_82
          blender_2_83
          blender_2_90
          blender_2_91
          blender_2_92
          blender_2_93
          blender_3_0
          blender_3_1
          blender_3_2
          blender_3_3
          blender_3_4
          blender_3_5
          blender_3_6
          blender_4_0;
        default = blender_4_0;
      };

      checks.x86_64-linux = {
        blender_2_79 = mkTest { blender = self.packages.x86_64-linux.blender_2_79; };
        blender_2_81 = mkTest { blender = self.packages.x86_64-linux.blender_2_81; };
        blender_2_82 = mkTest { blender = self.packages.x86_64-linux.blender_2_82; };
        blender_2_83 = mkTest { blender = self.packages.x86_64-linux.blender_2_83; };
        blender_2_90 = mkTest { blender = self.packages.x86_64-linux.blender_2_90; };
        blender_2_91 = mkTest { blender = self.packages.x86_64-linux.blender_2_91; };
        blender_2_92 = mkTest { blender = self.packages.x86_64-linux.blender_2_92; };
        blender_2_93 = mkTest { blender = self.packages.x86_64-linux.blender_2_93; };
        blender_3_0  = mkTest { blender = self.packages.x86_64-linux.blender_3_0; };
        blender_3_1  = mkTest { blender = self.packages.x86_64-linux.blender_3_1; };
        blender_3_2  = mkTest { blender = self.packages.x86_64-linux.blender_3_2; };
        blender_3_3  = mkTest { blender = self.packages.x86_64-linux.blender_3_3; };
        blender_3_4  = mkTest { blender = self.packages.x86_64-linux.blender_3_4; };
        blender_3_5  = mkTest { blender = self.packages.x86_64-linux.blender_3_5; };
        blender_3_6  = mkTest { blender = self.packages.x86_64-linux.blender_3_6; };
        blender_4_0  = mkTest { blender = self.packages.x86_64-linux.blender_4_0; };
      };

    };
}
