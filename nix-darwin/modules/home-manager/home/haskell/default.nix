{ pkgs, ... }:
{
  home.packages = with pkgs; [
    elixir
    elixir-ls
    cabal-install
    stack
  ];
}
