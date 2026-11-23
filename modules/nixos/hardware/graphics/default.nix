{ lib, ... }:
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
}
