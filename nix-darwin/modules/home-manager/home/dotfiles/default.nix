{ pkgs, ... }:
let
  catppuccin-lazygit = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "lazygit";
    rev = "30bff2e6d14ca12a09d71e5ce4e6a086b3e48aa6";
    sha256 = "sha256-mmNA7MpORvdCb37myo2QqagPK46rxRxD0dvUMsHegEM=";
  };
in
{
  home.file.".inputrc".source = ./inputrc;

  home.file.".config/alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;
  home.file.".config/alacritty/catppuccin-macchiato.yml".source =
    ./alacritty/catppuccin-macchiato.yml;

  home.file.".config/ghostty/config".source = ./ghostty/config;

  home.file.".zsh/starship.zsh".source = ./zsh/starship.zsh;
  home.file.".zsh/aliases.zsh".source = ./zsh/aliases.zsh;
  home.file.".zsh/integrations.zsh".source = ./zsh/integrations.zsh;

  home.file.".config/ohmyposh/zen.toml".source = ./ohmyposh/zen.toml;

  home.file.".local/scripts/tmux-sessionizer" = {
    source = ../scripts/tmux/tmux-sessionizer.sh;
    executable = true;
  };

  home.file.".local/scripts/tmux-cht.sh" = {
    source = ../scripts/tmux/tmux-cht.sh;
    executable = true;
  };

  home.file.".tmux-cht-languages" = {
    source = ./tmux/.tmux-cht-languages;
    executable = true;
  };

  home.file.".tmux-cht-command" = {
    source = ./tmux/.tmux-cht-command;
    executable = true;
  };

  home.file.".config/aerospace/aerospace.toml" = {
    source = ./aerospace/aerospace.toml;
    executable = true;
  };

  home.file.".config/nushell/config.nu" = {
    source = ./nushell/config.nu;
    executable = true;
  };

  home.file.".config/nushell/env.nu" = {
    source = ./nushell/env.nu;
    executable = true;
  };

  home.file.".config/tmux/tmux.reset.conf" = {
    source = ./tmux/tmux.reset.conf;
    executable = true;
  };

  home.file.".config/starship/starship.toml".source = ./starship/starship.toml;

  home.file.".config/skhd/skhdrc" = {
    source = ./skhd/skhdrc;
    executable = true;
  };

  home.file.".config/yazi/yazi.toml".source = ./yazi/yazi.toml;

  home.file.".config/yabai/yabairc" = {
    source = ./yabai/yabairc;
    executable = true;
  };

  home.file.".config/zellij/config.kdl" = {
    source = ./zellij/config.kdl;
    executable = true;
  };

  home.file.".gitkraken/themes/catppuccin-macchiato-theme.jsonc" = {
    source = ./gitkraken/themes/catppuccin-macchiato-theme.jsonc;
    executable = true;
  };

  home.file.".gitkraken/themes/catppuccin-mocha-theme.jsonc" = {
    source = ./gitkraken/themes/catppuccin-mocha-theme.jsonc;
    executable = true;
  };

  home.file.".local/bin/zet" = {
    source = ../scripts/second-brain/zet;
    executable = true;
  };

  home.file."personal/themes/lazygit" = {
    source = catppuccin-lazygit;
    executable = true;
  };
}
