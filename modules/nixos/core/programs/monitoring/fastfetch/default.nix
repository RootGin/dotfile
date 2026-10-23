{
  inputs,
  config,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  environment.systemPackages = with pkgs; [ fastfetch ];

  home-manager.users.${username} = _: {
    home.file = {
      ".config/fastfetch/config.jsonc".source = ./config.jsonc;
      ".config/fastfetch/nixos.png".source = ./nixos.png;
    };
  };
}
