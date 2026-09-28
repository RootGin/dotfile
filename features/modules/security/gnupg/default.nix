{ self, inputs, ... }:
{
  flake.nixosModules.modulesSecurityGnupg =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      options.securityModule.gpg = {
        enable = lib.mkEnableOption "Enable the gpg module";
      };

      config = lib.mkIf config.securityModule.gpg.enable {
        home-manager.users.${username} = _: {
          programs.gpg.enable = true;

          services.gpg-agent = {
            enable = true;
            enableSshSupport = true;
            pinentry.package = pkgs.pinentry-gnome3;

            defaultCacheTtlSsh = 14400;
            maxCacheTtlSsh = 14400;

            sshKeys = [
              "587D78D19A259FBDE134311DB11AE28644C4EFE5"
            ];
          };
        };
      };
    };
}
