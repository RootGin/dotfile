{
  config.my.hardware = {
    gpu = {
      enable = true;
      brand = "amd";
      prime = {
        enable = true;
        igpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  config.boot.blacklistedKernelModules = [ "nouveau" ];
}
