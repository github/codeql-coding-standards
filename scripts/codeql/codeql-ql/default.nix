let
    pkgs = import <nixpkgs> {};
in
{
    codeql-ql-0_1_0-dev = pkgs.callPackage ./0.0.1-dev.nix {};
}