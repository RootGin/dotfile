{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  programs.fish.enable = true;
  users.users.${username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
      "openrazer"
      "input"
      "video"
    ];
  }
  // lib.optionalAttrs (config.security.agenix.enable) {
    hashedPasswordFile = config.age.secrets."rootgin-password-hash".path;
  };
  users.defaultUserShell = pkgs.fish;
}
