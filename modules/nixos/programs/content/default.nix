{
  config,
  lib,
  pkgs,
  ...
}:

let
  defaultPackages = [
    pkgs.blockbench
  ];
in
{
  options.my.programs.content = {
    enable = lib.mkEnableOption "Enable content creation tools";

    optionalPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = [
        pkgs.davinci-resolve-studio
      ];
      description = "List of optional packages to install alongside the default ones.";
    };
  };

  config = lib.mkIf config.my.programs.content.enable {
    environment.systemPackages = defaultPackages ++ config.my.programs.content.optionalPackages;

    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
        obs-vkcapture
        obs-pipewire-audio-capture
      ];
    };
  };
}
