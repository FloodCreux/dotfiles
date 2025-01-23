{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ less ];
}
