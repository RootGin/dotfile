{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.security.encryption.passwords = {
    enable = lib.mkEnableOption "Enable passwords module";
  };

  config = lib.mkIf config.my.security.encryption.passwords.enable {
    environment = {
      systemPackages = with pkgs; [
        bitwarden-desktop
        proton-authenticator
      ];
    };
  };
}
