{
    config.my.hardware = {
      gpu.enable = true;
      gpu.brand = "amd";
    };

    config.boot.blacklistedKernelModules = [ "nouveau" ];
  }
