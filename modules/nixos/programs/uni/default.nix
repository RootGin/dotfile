{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.uni = {
    enable = lib.mkEnableOption "Enable uni module aka tex shit";
  };

  config = lib.mkIf config.my.programs.uni.enable {
    environment.systemPackages = with pkgs; [
      texliveFull
    ];
  };
}
