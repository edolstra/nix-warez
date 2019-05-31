with import <nixpkgs> { system = "x86_64-linux"; };

let

  mkBlender = { name, src }:
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
  blender_2_79 = mkBlender {
    name = "blender-bin-2.79-d83a72ec104c";
    src = fetchurl {
      url = https://builder.blender.org/download/blender-2.79-d83a72ec104c-linux-glibc224-x86_64.tar.bz2;
      sha256 = "1ixh76cnfzwvvv5ycxr7kfy6fxs14mvx4p2y6y7qmgm0p719whgi";
    };
  };

  blender_2_80 = mkBlender {
    name = "blender-bin-2.80-3b8ae2c08f5c";
    src = fetchurl {
      url = https://builder.blender.org/download/blender-2.80-3b8ae2c08f5c-linux-glibc224-x86_64.tar.bz2;
      sha256 = "1g12bmvrqs3xdyy7qic81nhai362k6s238r5qj7f2hbalcyd2raq";
    };
  };
}

