{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./genpw.nix {}
