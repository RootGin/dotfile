{ config, ... }:
let
  myAliases = import ./commonAliases.nix;
  username = config.my.user.username;
in
{
  home-manager.users.${username} = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
    };

    programs.direnv.enableBashIntegration = true;
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
