{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dotnet-sdk
    omnisharp-roslyn
    roslyn
    csharp-ls
    netcoredbg
    csharpier
  ];
}
