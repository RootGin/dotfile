{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  imports = [
    ./bash.nix
  ];

  home-manager.users.${username} = lib.mkIf config.my.desktop.enable {
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
  environment.systemPackages =
    (with pkgs; [
      acpi
      bat
      bat-extras.batman
      eza
      glow
      unzip
      zoxide
    ])
    ++ lib.optionals config.my.desktop.enable (
      with pkgs;
      [
        clang
        deadnix
        gh
        nixd
        nixfmt
        statix
      ]
    );
}
