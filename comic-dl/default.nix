with import <nixpkgs> {};
with python3Packages;

let

  cfscrape = buildPythonPackage rec {
    pname = "cfscrape";
    version = "2.0.8";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1f7cv2j08y4m6hz8z8nqljmpsw0jiy4ahaxddxwssf9gzywkr4am";
    };

    buildInputs = [ requests ];
  };

/*
  cfscrape = buildPythonPackage rec {
    pname = "cfscrape";
    version = "2.0.3";

    src = fetchFromGitHub {
      owner = "lukele";
      repo = "cloudflare-scrape";
      rev = "6c004e80516ab9d19082645fc01b614287433a8f";
      sha256 = "0c5kfnmghpj506kw5jfgcbrsjlxcx38q13x3lg1zxnagli3wxbqp";
    };

    buildInputs = [ requests ];
  };
*/

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
  version = "2019.05.26";

  src = fetchzip {
    url = "https://github.com/Xonshiz/comic-dl/archive/${version}.tar.gz";
    sha256 = "1bykkvvd5v3k21mrl5wkzqf0z5j0pnzl92ws2jqwhqlscwd5f956";
  };

  patches = [ ./install.patch ];

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