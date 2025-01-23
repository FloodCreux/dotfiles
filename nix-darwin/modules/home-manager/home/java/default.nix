{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jdk8
    # jdk17
  ];
}
