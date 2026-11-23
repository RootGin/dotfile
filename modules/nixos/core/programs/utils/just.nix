{
  config,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  environment.systemPackages = with pkgs; [
    just
  ];

  home-manager.users.${username} = {
    home.file = {
      ".justfile".source = ../../../../../justfile;
      ".config/just/justfile".source = ../../../../../justfile;
    };
  };
}
