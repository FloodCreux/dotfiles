{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc
    ghc
    cmake
    raylib
  ];
}
