{ lib, stdenv, fetchzip, withExtractors ? [], withPacks ? [] }:

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

  buildInputs = if (lib.length withExtractors)  == 0 then [ ] else withExtractors;
  inherit withExtractors withPacks;

  installPhase = ''
    # codeql directory should not be top-level, otherwise,
    # it'll include /nix/store to resolve extractors.
    mkdir -p $out/{codeql/qlpacks,bin}
    cp -R * $out/codeql/

    ln -s $out/codeql/codeql $out/bin/

    for extractor in $withExtractors; do
      # Copy the extractor, because CodeQL doesn't follow symlinks.
      cp -R $extractor $out/codeql/ql
    done

    for pack in $withPacks ; do
      # Copy the pack, because CodeQL doesn't follow symlinks.
      cp -R $pack/ $out/codeql/qlpacks/
    done
  '';


  meta = with lib; {
    description = "Semantic code analysis engine";
    homepage = "https://codeql.github.com";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    license = licenses.unfree;
  };
}