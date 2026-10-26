{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  myAliases = (import ./commonAliases.nix);
  username = config.my.user.username;
in
{
  options.my.shell.fish = {
    enable = lib.mkEnableOption "Enable fish Module";
  };

  config = lib.mkIf config.my.shell.fish.enable {
    environment.shells = with pkgs; [ fish ];
    environment.systemPackages = with pkgs; [ fzf ];

    programs.fish.enable = true;

    home-manager.users.${username} = {
      home.file.".config/fish/conf.d/tide.fish".source = ./tide/tide.fish;
      programs.fish = {
        enable = true;
        shellAliases = myAliases;
        plugins = [
          {
            name = "tide";
            src = pkgs.fishPlugins.tide.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
          {
            name = "autopair";
            src = pkgs.fishPlugins.autopair.src;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge.src;
          }
          {
            name = "puffer";
            src = pkgs.fishPlugins.puffer.src;
          }
        ];
        interactiveShellInit = ''
          zoxide init --cmd cd fish | source
        '';
      };
    };
  };
}
