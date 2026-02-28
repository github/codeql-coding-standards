{ stdenv, lib, fetchFromGitHub, rustPlatform, gh, libiconv, which, jq, withCodeQlCli }:

stdenv.mkDerivation rec {
    pname = "codeql-ql";
    version = "0.1.0-dev";

    dontConfigure = true;
    dontStrip = true;
    dontInstall = true;
    dontFixup = true;

    src = fetchFromGitHub {
        owner = "github";
        repo = "codeql";
        rev = "codeql-cli/v2.16.0";
        sha256 = "x2EFoOt1MZRXxIZt6hF86Z1Qu/hVUoOVla562TApVwo=";
    };

    nativeBuildInputs = [ gh libiconv which withCodeQlCli jq];

    platform = if stdenv.isLinux then "linux64" else "osx64";

    buildPhase = ''
        runHook preBuild
        mkdir -p $out
        codeql pack create --threads=0 --output=$out --no-default-compilation-cache --compilation-cache=$TMP_DIR ql/ql/src
        runHook postBuild
    '';
}