{ inputs, config, ... }:
let
  username = config.my.user.username;
in
{
  home-manager.users.${username} = _: {
    home.file = {
      ".config/zsh/.p10k.zsh".source = ./p10k.zsh;
    };
  };
}
