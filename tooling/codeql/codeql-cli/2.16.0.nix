{ lib, stdenv, fetchzip, jdk17, withExtractors ? [], withPacks ? [] }:

stdenv.mkDerivation rec {
  pname = "codeql-cli";
  version = "2.16.0";
  platform = if stdenv.isDarwin then "osx64" else "linux64";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  src = fetchzip {
    url = "https://github.com/github/codeql-cli-binaries/releases/download/v${version}/codeql-${platform}.zip";
    hash = if platform == "osx64" then "sha256-trWUSMOT7h7J5ejjp9PzhGgBS3DYsJxzcv6aYKuk8TI=" else "sha256-ztvKlNbqWcH93AB/Mum9jM81ssxiGcbkBROEANFGXis=";
  };

  buildInputs = if (lib.length withExtractors)  == 0 then [ ] else withExtractors;
  inherit withExtractors withPacks;

  nativeBuildInputs = [ jdk17 ];

  installPhase = ''
    # codeql directory should not be top-level, otherwise,
    # it'll include /nix/store to resolve extractors.
    mkdir -p $out/{codeql/qlpacks,bin}
    cp -R * $out/codeql/


    if [ "$platform" == "linux64" ]; then
      ln -sf $out/codeql/tools/linux64/lib64trace.so $out/codeql/tools/linux64/libtrace.so
    fi
      
    # many of the codeql extractors use CODEQL_DIST + CODEQL_PLATFORM to
    # resolve java home, so to be able to create databases, we want to make
    # sure that they point somewhere sane/usable since we can not autopatch
    # the codeql packaged java dist, but we DO want to patch the extractors
    # as well as the builders which are ELF binaries for the most part
    rm -rf $out/codeql/tools/$platform/java
    ln -s ${jdk17} $out/codeql/tools/$platform/java

    ln -s $out/codeql/codeql $out/bin/

    for extractor in $withExtractors; do
      # Copy the extractor, because CodeQL doesn't follow symlinks.
      cp -R $extractor $out/codeql/ql
    done

    for pack in $withPacks ; do
      # Copy the pack, because CodeQL doesn't follow symlinks.
      cp -R $pack/* $out/codeql/qlpacks/
    done
  '';


  meta = with lib; {
    description = "Semantic code analysis engine";
    homepage = "https://codeql.github.com";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    license = licenses.unfree;
  };
}