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
  options.my.hardware = {
    gpu = {
      enable = lib.mkEnableOption "Enable GPU support";
      brand = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "nvidia"
            "amd"
            "intel"
          ]
        );
        default = null;
        example = "nvidia";
        description = "Primary GPU brand/vendor. null means no vendor-specific config.";
      };
      prime = {
        enable = lib.mkEnableOption "Enable NVIDIA PRIME offload (hybrid graphics)";
        igpuBusId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "PCI:5:0:0";
          description = "PCI bus ID of the integrated GPU (AMD or Intel).";
        };
        nvidiaBusId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "PCI:1:0:0";
          description = "PCI bus ID of the NVIDIA discrete GPU.";
        };
      };
    };
  };

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
          amdgpuBusId = mkIf (
            cfg.gpu.brand == "amd" && cfg.gpu.prime.igpuBusId != null
          ) cfg.gpu.prime.igpuBusId;
          intelBusId = mkIf (
            cfg.gpu.brand == "intel" && cfg.gpu.prime.igpuBusId != null
          ) cfg.gpu.prime.igpuBusId;
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
