let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0e148322b344eab7c8d52f6e59b0d95ba73fb62e.tar.gz";
  pkgs = (import nixpkgs { config = {}; overlays = []; }) // (import ./all-tools.nix);
in

pkgs.mkShell {
  packages = with pkgs; [
    clang-tools_14
    python39
    git
    gh
    jq
    codeql-cli-2_16_0-with-ql
  ];
}