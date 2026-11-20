{
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
  options.my.shell.zsh = {
    enable = lib.mkEnableOption "Enable zsh Module";
  };

  config = lib.mkIf config.my.shell.zsh.enable {
    environment.shells = with pkgs; [ zsh ];

    home-manager.users.${username} = {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        autosuggestion.strategy = [ "completion" ];
        dotDir = "/home/${username}/.config/zsh";
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        shellAliases = myAliases;
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "zsh-nix-shell";
            src = pkgs.zsh-nix-shell;
            file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
          }
        ];
        initContent = ''
          POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          source ~/.config/zsh/.p10k.zsh
        '';
      };

      programs.direnv.enableZshIntegration = true;
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
      };
    };
  };
}
