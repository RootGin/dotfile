{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.my.services.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak service";
  };

  config = lib.mkIf config.my.services.flatpak.enable {
    services.flatpak = {
      enable = true;
      update.onActivation = true;
    };
  };
}
