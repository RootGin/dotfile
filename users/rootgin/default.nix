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
  users.mutableUsers = lib.mkDefault true;
  users.users.${username} = {
    shell = pkgs.fish;
    isNormalUser = true;
    initialPassword = lib.mkDefault "rootgin";
    openssh.authorizedKeys.keys = lib.mkDefault [ ];
    extraGroups = [
      "wheel"
      "input"
      "video"
    ]
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.my.hardware.razer.enable "openrazer";
  }
  // lib.optionalAttrs (config.security.agenix.enable) {
    hashedPasswordFile = config.age.secrets."rootgin-password-hash".path;
  };
  users.defaultUserShell = pkgs.fish;
}
