{ stdenv, lib, fetchFromGitHub, rustPlatform, gh, libiconv, which, jq}:

rustPlatform.buildRustPackage rec {
    pname = "codeql-ql-extractor";
    version = "0.0.1";

    dontConfigure = true;
    dontStrip = true;

    src = fetchFromGitHub {
        owner = "github";
        repo = "codeql";
        rev = "codeql-cli/v2.16.0";
        sha256 = "x2EFoOt1MZRXxIZt6hF86Z1Qu/hVUoOVla562TApVwo=";
    };

    sourceRoot = "${src.name}/ql";

    cargoLock = {
        lockFile = "${src.outPath}/ql/Cargo.lock";
        outputHashes = {
            "tree-sitter-json-0.20.0" = "sha256-fIh/bKxHMnok8D+xQlyyp5GaO2Ra/U2Y/5IjQ+t4+xY=";
            "tree-sitter-ql-0.19.0" = "sha256-2QOtNguYAIhIhGuVqyx/33gFu3OqcxAPBZOk85Q226M=";
            "tree-sitter-ql-dbscheme-0.0.1" = "sha256-wp0LtcbkP2lxbmE9rppO9cK+RATTjZxOb0EWfdKT884=";
        };
    };

    nativeBuildInputs = [ gh libiconv which jq];

    platform = if stdenv.isLinux then "linux64" else "osx64";

    installPhase = ''
        runHook preInstall
        mkdir -p $out/tools/$platform
        cargo run --profile release --bin codeql-extractor-ql -- generate --dbscheme ql/src/ql.dbscheme --library ql/src/codeql_ql/ast/internal/TreeSitter.qll
        # For some reason the fixupPhase isn't working, so we do it manually
        patchShebangs tools/
        cp -r codeql-extractor.yml tools ql/src/ql.dbscheme ql/src/ql.dbscheme.stats $out/
        cp $(cargo metadata --format-version 1 | jq -r '.target_directory')/release/codeql-extractor-ql $out/tools/$platform/extractor
        runHook postInstall
        '';
}