{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ carapace ];
}
