with import <nixpkgs> {};

assert stdenv.system == "x86_64-linux";

stdenv.mkDerivation {
  name = "visualsfm-0.5.25";

  src = fetchurl {
    url = http://ccwu.me/vsfm/download/VisualSFM_linux_64bit.zip;
    sha256 = "1nfjc9w1xr4kgrbbys9m0yrqxj8bm53m4wvp6mhxibp5g8kgqaq5";
  };

  buildInputs = [ unzip pkgconfig gtk2 mesa_glu ];

  installPhase =
    ''
      mkdir -p $out/bin
      cp bin/VisualSFM $out/bin/
    '';
}
