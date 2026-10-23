{
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.my.user.username;
    in
    {
      imports = [
        ./waydroid.nix
      ];
      options.my.programs.emulation = {
        enable = lib.mkEnableOption "Enabled the emulation programs";
      };

      config = lib.mkIf config.my.programs.emulation.enable {
        environment.systemPackages = with pkgs; [
          docker-compose
          #winboat
        ];
        home-manager.users.${username}.home.packages = with pkgs; [
          qemu
          quickemu
        ];
        programs.virt-manager.enable = true;
        users.users.${username}.extraGroups = [ "libvirtd" ];
        virtualisation = {
          docker.enable = true;
          libvirtd.enable = true;
          spiceUSBRedirection.enable = true;
        };
      };
    }
