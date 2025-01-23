{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ zigpkgs.master ];
}
