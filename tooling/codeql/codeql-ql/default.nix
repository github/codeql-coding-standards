let
    nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0e148322b344eab7c8d52f6e59b0d95ba73fb62e.tar.gz";
    pkgs = (import nixpkgs { config = {}; overlays = []; });
in
{
    codeql-ql-0_1_0-dev = pkgs.callPackage ./0.0.1-dev.nix {};
}