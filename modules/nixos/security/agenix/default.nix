{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
  secretsDir = ../../../../secrets;
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  options.security.agenix = {
    enable = lib.mkEnableOption "Enable agenix secret management";
  };

  config = lib.mkIf config.security.agenix.enable {
    age = {
      identityPaths = [
        "/etc/agenix/age.key"
        "/home/${username}/.config/agenix/age.key"
      ];

      secrets = {
        "deepseek-api-key" = {
          file = "${secretsDir}/deepseek-api-key.age";
        };

        "qwen-api-key" = {
          file = "${secretsDir}/qwen-api-key.age";
        };

        "rootgin-password-hash" = {
          file = "${secretsDir}/rootgin-password-hash.age";
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      age
      openssl
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
