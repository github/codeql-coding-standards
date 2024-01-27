let
    pkgs = import <nixpkgs> {};
in
{
    ql-extractor-0_0_1 = pkgs.callPackage ./0.0.1.nix {};
}