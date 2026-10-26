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
  users.mutableUsers = lib.mkDefault true;
  users.users.${username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    initialPassword = lib.mkDefault "rootgin";
    openssh.authorizedKeys.keys = lib.mkDefault [ ];
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
