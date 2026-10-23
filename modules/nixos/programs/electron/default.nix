{ inputs, config, ... }:
let
  username = config.my.user.username;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager.users.${username} = {
    home.file = {
      ".config/electron-flags.conf".source = ./electron-flags.conf;
    };
  };
}
