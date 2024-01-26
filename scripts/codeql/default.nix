let
    pkgs = import <nixpkgs> {};
in
rec {
    ql-extractor_0_0_1 = pkgs.callPackage ./ql-extractor/0.0.1.nix {inherit codeql-cli_2_16_0;};
    codeql-cli_2_16_0 = pkgs.callPackage ./codeql-cli/2.16.0.nix {};
    codeql-cli_2_16_0_with_ql_extractor = pkgs.callPackage ./codeql-cli/2.16.0.nix { withQlExtractor = ql-extractor_0_0_1; };

}