{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;
  cfg = config.my.hardware;
in
{
  config = mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }

    # NVIDIA specifics (standalone or PRIME offload)
    (mkIf (cfg.gpu.enable && (cfg.gpu.brand == "nvidia" || cfg.gpu.prime.enable)) {
      services.xserver.videoDrivers =
        if cfg.gpu.prime.enable && cfg.gpu.brand == "amd" then
          [
            "amdgpu"
            "nvidia"
          ]
        else if cfg.gpu.prime.enable && cfg.gpu.brand == "intel" then
          [
            "modesetting"
            "nvidia"
          ]
        else
          [ "nvidia" ];

      boot.kernelModules = [ "nvidia-uvm" ];

      services.switcherooControl.enable = cfg.gpu.prime.enable;

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = cfg.gpu.prime.enable;
        open = true;
        nvidiaSettings = true;
        #package = config.boot.kernelPackages.nvidiaPackages.stable;

        prime = mkIf cfg.gpu.prime.enable {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          amdgpuBusId = mkIf (cfg.gpu.brand == "amd" && cfg.gpu.prime.igpuBusId != null) cfg.gpu.prime.igpuBusId;
          intelBusId = mkIf (cfg.gpu.brand == "intel" && cfg.gpu.prime.igpuBusId != null) cfg.gpu.prime.igpuBusId;
          nvidiaBusId = mkIf (cfg.gpu.prime.nvidiaBusId != null) cfg.gpu.prime.nvidiaBusId;
        };
      };
    })

    # Intel specifics
    (mkIf (cfg.gpu.enable && cfg.gpu.brand == "intel") {
      hardware.graphics.extraPackages = with pkgs; [
        vpl-gpu-rt
        # intel-media-sdk  # uncomment for older Gen (pre-Xe) iGPUs
      ];
    })
  ];
}
