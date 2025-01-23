{ pkgs, username, ... }:
{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = "${pkgs.nushell}/bin/nu";
  };
}
