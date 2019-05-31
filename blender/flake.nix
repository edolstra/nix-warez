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

in

{
  name = "blender-bin";

  epoch = 2019;

  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs = [ "nixpkgs" ];

  outputs = inputs: rec {

    packages = let pkgs = inputs.nixpkgs.outputs.legacyPackages; in {

      blender_2_79 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.79-d83a72ec104c";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.79-054dbb833e15-linux-glibc224-x86_64.tar.bz2;
          hash = "sha256-4gaUtZMo60R585Vku0XEbBL1uFUtKYlspgGDh+g2Pn4=";
        };
      };

      blender_2_80 = mkBlender {
        inherit pkgs;
        name = "blender-bin-2.80-fc336f973d52";
        src = import <nix/fetchurl.nix> {
          url = https://builder.blender.org/download/blender-2.80-fc336f973d52-linux-glibc224-x86_64.tar.bz2;
          hash = "sha256-B+5fM482tj3PQbdCI9wE2AtHI4kPdIK+aMbkFxXTwhY=";
        };
      };

    };

    defaultPackage = packages.blender_2_80;

  };
}

