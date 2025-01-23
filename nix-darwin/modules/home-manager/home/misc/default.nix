{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp
    hadoop
    chafa
  ];
}
