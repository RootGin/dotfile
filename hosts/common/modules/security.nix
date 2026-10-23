{ self, inputs, ... }:
{
  flake.nixosModules.hostCommonModulesSecurity = {
    config.my.security = {
      encryption = {
        passwords.enable = true;
      };
      gpg.enable = true;
    };
  };
}
