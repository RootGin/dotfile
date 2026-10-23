{
  config,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  environment.sessionVariables = {
    RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
  };
  environment.systemPackages = with pkgs; [
    ripgrep
  ];

  home-manager.users.${username} = {
    home.file.".ripgreprc".text = ''
      --glob=!.git/*
      --glob=!flake.lock
    '';
  };
}
