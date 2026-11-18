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
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.8.0";
              sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
            };
          }
        ];
        initContent = ''
          POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          source ~/.config/zsh/.p10k.zsh
          eval "$(direnv hook zsh)"
          eval "$(zoxide init --cmd cd zsh)"
        '';
      };
    };
  };
}
