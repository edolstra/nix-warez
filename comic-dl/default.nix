with import <nixpkgs> {};
with python3Packages;

let

  cfscrape = buildPythonPackage rec {
    pname = "cfscrape";
    version = "1.9.7";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0fh97spqv69r0amcbjhhkl5nbjc2dmddsv91fw9lcbw7wrrc2zzs";
    };

    buildInputs = [ requests ];
  };

  bs4 = buildPythonPackage rec {
    pname = "bs4";
    version = "0.0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0fnxhql23ql6q5n64xjknx3sc3fm4vgpbw0z99p0qp6cswgymv1n";
    };

    propagatedBuildInputs = [ beautifulsoup4 ];
  };

  aiocoap = buildPythonPackage rec {
    pname = "aiocoap";
    version = "0.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1xmfqnljm3avgril08girgg225fyw086wnxgcqfhp3bdvd8l2ba0";
    };

    doCheck = false;
  };

  sites = buildPythonPackage rec {
    pname = "sites";
    version = "0.0.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1zhadrngs1qs2p85vq22jx2qlr9qwqgmc01jg6d4whqs6a9hz8aq";
    };

    buildInputs = [ aiohttp aiocoap werkzeug ];
  };

  pdfrw = buildPythonPackage rec {
    pname = "pdfrw";
    version = "0.4";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1x1yp63lg3jxpg9igw8lh5rc51q353ifsa1bailb4qb51r54kh0d";
    };

    #buildInputs = [ pillow ];
  };

  img2pdf = buildPythonPackage rec {
    pname = "img2pdf";
    version = "0.3.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1ksn33j9d9df04n4jx7dli70d700rafbm37gjaz6lwsswrzc2xwx";
    };

    buildInputs = [ pillow ];

    doCheck = false;
  };

in

buildPythonApplication rec {
  pname = "comic-dl-${version}";
  version = "2019.01.26";

  src = fetchzip {
    url = "https://github.com/Xonshiz/comic-dl/archive/${version}.tar.gz";
    sha256 = "15src2385xq5x5l2fhyf227pdkzz304sskjjnrzngl56jqkyqish";
  };

  postInstall = ''
    mkdir -p $out/bin
    cp $out/lib/python3.7/site-packages/comic_dl/__main__.py $out/bin/comic-dl
    chmod +x $out/bin/comic-dl
  '';

  postFixup = ''
    wrapProgram $out/bin/comic-dl --prefix PYTHONPATH : $out/lib/python3.7/site-packages/comic_dl
  '';

  pythonPath = [ requests more-itertools selenium cfscrape bs4 tqdm sites img2pdf pillow nodejs ];

  doCheck = false;

  meta = {
    homepage = https://github.com/Xonshiz/comic-dl;
  };
}