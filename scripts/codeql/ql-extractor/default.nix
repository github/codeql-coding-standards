let
    pkgs = import <nixpkgs> {};
in
{
    ql-extractor_0_0_1 = pkgs.callPackage ./0.0.1.nix {};
}