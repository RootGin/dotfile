{ self, inputs, ... }:
{
  flake.nixosModules.modulesShell =
    { config, pkgs, ... }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager

        self.nixosModules.modulesShellBash
        self.nixosModules.modulesShellP10k
        self.nixosModules.modulesShellZsh
      ];

      home-manager.users.${username} = {
        programs.git = {
          enable = true;
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
        tirith
        unzip
        zoxide
      ];
    };
}
