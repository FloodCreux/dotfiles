{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
    shell = "${pkgs.nushell}/bin/nu";
    terminal = "xterm-256color";
  };
}
