{ config, lib, ... }:
let
  username = config.my.user.username;
in
{
  config = lib.mkIf config.my.shell.zsh.enable {
    home-manager.users.${username} = {
      home.file.".config/zsh/.p10k.zsh".source = ./p10k.zsh;
    };
  };
}
