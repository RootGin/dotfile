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
  imports = [
    ./bash.nix
    ./p10k
    ./zsh.nix
    ./fish.nix
  ];

  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        push.autoSetupRemote = "true";
        user = {
          name = "RootGin";
          email = "rootgin@proton.me";
        };
        credential = {
          helper = "!gh auth git-credential";
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    direnv
    nix-direnv
    acpi
    bat
    bat-extras.batman
    clang
    deadnix
    eza
    gh
    glow
    nixd
    nixfmt
    statix
    unzip
    zoxide
  ];
}
