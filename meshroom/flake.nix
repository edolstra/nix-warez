{
  description = "A free, open-source 3D Reconstruction Software based on the AliceVision framework (upstream binaries)";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:

    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };
    in {
      overlays.default = final: prev: {
        meshroom = let
          python3 = pkgs.python37;
        in prev.stdenvNoCC.mkDerivation rec {
          pname = "meshroom-bin";
          version = "2021.1.0";
          src = import <nix/fetchurl.nix> {
            url = "https://github.com/alicevision/meshroom/releases/download/v${version}/Meshroom-${version}-linux-cuda10.tar.gz";
            hash = "sha256-3pTrJktbMNVbNjKcR2FZa8xrTEQ7CWsLFayWOJLXnuQ=";
          };

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            cudaPackages.autoAddOpenGLRunpathHook
            libsForQt5.wrapQtAppsHook
            makeWrapper
          ];

          buildInputs = with pkgs; [
            e2fsprogs
            glib
            krb5
            zlib
            postgresql
            unixODBC
            cups
            speechd
            python3
            libsForQt5.qt5.qtwebengine
            libsForQt5.qt5.qtwebview
            libsForQt5.qt5.qtwebsockets
            libsForQt5.qt5.qttools
            gtk3
            atk
            gdk-pixbuf
            cairo
            pango
            libdrm
            libGLU
            libglvnd
            libglvnd
            ocl-icd
            xorg.libX11
            xorg.libXfixes
            xorg.libXi
            xorg.libXrender
            xorg.libXxf86vm
          ];

          installPhase = ''
            mkdir -p $out/opt/meshroom
            cp -r \
              Meshroom \
              meshroom_batch \
              meshroom_compute \
              qtPlugins \
              lib \
              aliceVision \
              $out/opt/meshroom

            mkdir -p $out/bin
            makeWrapper $out/opt/meshroom/Meshroom $out/bin/Meshroom --chdir $out/opt/meshroom
            makeWrapper $out/opt/meshroom/meshroom_batch $out/bin/meshroom_batch --chdir $out/opt/meshroom
            makeWrapper $out/opt/meshroom/meshroom_compute $out/bin/meshroom_compute --chdir $out/opt/meshroom
          '';

          postFixup = ''
            patchelf --debug --add-needed libpython${pkgs.lib.versions.major python3.pythonVersion}.so \
              "$out/opt/meshroom/Meshroom"
          '';

          meta.mainProgram = "meshroom";
        };
      };

      packages.x86_64-linux.default = pkgs.meshroom;

      checks.x86_64-linux = {
        meshroom = pkgs.runCommand "meshroom-test" {
          buildInputs = [
            pkgs.meshroom
          ];
        }
          ''
            Meshroom --help
            meshroom_compute --help
            meshroom_batch --help
            touch $out
          '';
      };
    };
}
