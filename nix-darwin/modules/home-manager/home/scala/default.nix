{ pkgs, ... }:
{
  home.packages = with pkgs; [
    metals
    coursier
    maven
    scala_2_12
    scalafmt
  ];
}
