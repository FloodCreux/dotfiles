{ ... }:
{
  system.stateVersion = 4;
  system.keyboard.enableKeyMapping = true;
  system.defaults = {
    finder = {
      AppleShowAllFiles = true;
      _FXShowPosixPathInTitle = true;
    };

    dock.autohide = true;

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 1;
    };
  };
}
