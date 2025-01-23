{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ oh-my-posh ];
}
