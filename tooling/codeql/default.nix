let
    nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0e148322b344eab7c8d52f6e59b0d95ba73fb62e.tar.gz";
    pkgs = (import nixpkgs { config = {}; overlays = []; });
in
rec {
    ql-extractor-0_0_1 = pkgs.callPackage ./ql-extractor/0.0.1.nix {};
    codeql-cli-2_16_0 = pkgs.callPackage ./codeql-cli/2.16.0.nix {};
    codeql-ql-0_0_1-dev = pkgs.callPackage ./codeql-ql/0.0.1-dev.nix { withCodeQlCli = codeql-cli-2_16_0; };
    codeql-cli-2_16_0-with-ql = pkgs.callPackage ./codeql-cli/2.16.0.nix { withExtractors = [ql-extractor-0_0_1]; withPacks = [codeql-ql-0_0_1-dev];};
}