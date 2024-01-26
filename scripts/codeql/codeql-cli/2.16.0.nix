{ lib, stdenv, fetchzip, withQlExtractor ? null}:

stdenv.mkDerivation rec {
  pname = "codeql-cli";
  version = "2.16.0";
  platform = if stdenv.isDarwin then "osx64" else "linux64";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  src = fetchzip {
    url = "https://github.com/github/codeql-cli-binaries/releases/download/v${version}/codeql-${platform}.zip";
    hash = "sha256-trWUSMOT7h7J5ejjp9PzhGgBS3DYsJxzcv6aYKuk8TI="; 
  };
  
  buildInputs = if isNull withQlExtractor then [ ] else [ withQlExtractor ];
  inherit withQlExtractor;

  installPhase = ''
    # codeql directory should not be top-level, otherwise,
    # it'll include /nix/store to resolve extractors.
    env
    mkdir -p $out/{codeql,bin}
    cp -R * $out/codeql/

    ln -s $out/codeql/codeql $out/bin/

    if [ -n "$withQlExtractor" ]; then
      # Copy the extractor, because CodeQL doesn't follow symlinks.
      cp -R $withQlExtractor $out/codeql/ql
    fi
  '';


  meta = with lib; {
    description = "Semantic code analysis engine";
    homepage = "https://codeql.github.com";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    license = licenses.unfree;
  };
}