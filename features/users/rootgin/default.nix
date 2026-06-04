{ self, inputs, ... }:
{

  flake.nixosModules.usersRootgin =
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
      programs.zsh.enable = true;
      users.users.${username} = {
        shell = pkgs.zsh;
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
      users.defaultUserShell = pkgs.zsh;
    };
}
