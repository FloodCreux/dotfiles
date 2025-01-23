{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sbt
    bloop
  ];
}
