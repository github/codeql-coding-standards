let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0e148322b344eab7c8d52f6e59b0d95ba73fb62e.tar.gz";
  pkgs = (import nixpkgs { config = {}; overlays = []; });
  codeql = import ./default.nix;
in

pkgs.mkShell {
  packages = with codeql; [
    codeql-cli_2_16_0
  ];
}
