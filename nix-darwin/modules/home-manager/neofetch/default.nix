{
  pkgs,
  lib,
  ...
}:

let
  configSrc = ./electric.conf;

  neofetchPath = lib.makeBinPath (
    with pkgs;
    [
      chafa
      imagemagick
    ]
  );

  neofetchSixelsSupport = pkgs.neofetch.overrideAttrs (old: {
    postInstall = ''
      wrapProgram $out/bin/neofetch --prefix PATH : ${neofetchPath}
    '';
  });
in
{
  home.packages = [
    pkgs.hyfetch
    neofetchSixelsSupport
  ];
  home.file."~/.config/hyfetch.json".source = ./hyfetch.json;
  home.file."~/.config/neofetch/config.conf".source = configSrc;
}
