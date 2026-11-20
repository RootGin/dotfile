{
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
    shell = lib.mkIf config.my.shell.fish.enable pkgs.fish;
    isNormalUser = true;
    initialPassword = lib.mkIf (!config.security.agenix.enable) (lib.mkDefault "rootgin");
    hashedPasswordFile = lib.mkIf config.security.agenix.enable config.age.secrets."rootgin-password-hash".path;
    openssh.authorizedKeys.keys = lib.mkDefault [ ];
    extraGroups = [
      "wheel"
      "input"
      "video"
    ]
    ++ lib.optional config.virtualisation.docker.enable "docker"
    ++ lib.optional config.my.hardware.razer.enable "openrazer";
  };
  users.defaultUserShell = lib.mkIf config.my.shell.fish.enable pkgs.fish;
}
