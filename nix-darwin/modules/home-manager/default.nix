{
  pkgs,
  username,
  ...
}:
let
  # Helper to import modules with pkgs or username
  importWith = path: args: import path args;
  # importUsername = path: importWith path { inherit username; };
  importPkgs = path: importWith path { inherit pkgs; };
  importAll =
    path:
    importWith path {
      inherit pkgs;
      inherit username;
    };
in
{
  imports = [
    (importAll ./home)
    (importPkgs ./bat)
    ./carapace
    ./direnv
    ./eza
    ./fzf
    ./git
    (importPkgs ./java)
    ./neofetch
    ./nushell
    ./ohmyposh
    ./password-store
    ./starship
    (importPkgs ./tmux)
    ./zellij
    ./zsh
  ];
}
