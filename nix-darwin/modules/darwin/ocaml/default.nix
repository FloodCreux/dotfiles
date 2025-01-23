{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ocaml
    opam
    dune_3
    ocamlPackages.ocamlformat
  ];
}
