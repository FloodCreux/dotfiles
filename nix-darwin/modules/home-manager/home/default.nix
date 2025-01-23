{ pkgs, username, ... }:
{
  # Don't change this unless you know what you're doing
  home.stateVersion = "24.05";

  home.enableNixpkgsReleaseCheck = false;

  imports = [
    ./clang
    ./containers
    ./csharp
    ./git
    ./haskell
    ./java
    ./lua
    ./misc
    ./nix
    ./node
    ./notes
    ./scala
    ./sql
    ./terraform
    ./zig
  ];

  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "nvim";
  };
}
