let
    nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0e148322b344eab7c8d52f6e59b0d95ba73fb62e.tar.gz";
    pkgs = (import nixpkgs { config = {}; overlays = []; });
in
{
    ql-extractor-0_0_1 = pkgs.callPackage ./0.0.1.nix {};
}