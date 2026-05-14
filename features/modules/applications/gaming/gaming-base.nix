{ self, ... }:
{
  flake.nixosModules.applicationsGamingBase =
    { config, lib, pkgs, ... }:
    let
      cfg = config.programs.gaming;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.gamemode.enable = lib.mkDefault cfg.gamemode.enable;
        hardware.steam-hardware.enable = lib.mkDefault true;

        services.udev.extraRules = ''
          # Thrustmaster T.16000M joystick
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="b10a", TAG+="uaccess"

          # Common gaming controllers
          KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
        '';

        environment.systemPackages = with pkgs; [
          mangohud
          goverlay
        ] ++ cfg.extraPackages;
      };
    };
}
