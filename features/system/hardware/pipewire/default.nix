{ self, inputs, ... }:
{
  flake.nixosModules.coreHardwarePipewire =
    {
      config,
      pkgs,
      ...
    }:
    let
      EQPath = ".config/pipewire/EQ.txt";
      username = config.userOptions.username;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        audio.enable = true;
        jack.enable = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          configPackages = [
            (pkgs.writeTextDir "share/bluetooth.lua.d/51-bluez-config.lua" ''
              bluez_monitor.properties = {
                ["bluez5.enable-sbc-xq"] = true,
                ["bluez5.enable-msbc"] = true,
                ["bluez5.enable-hw-volume"] = true,
                ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
              }
            '')
          ];
        };
      };
      environment.systemPackages = [
        pkgs.crosspipe
      ];
      home-manager.users.${username} = _: {
        home.file = {
          ".config/pipewire/pipewire.conf.d/my-parametric-equalizer.conf".text = ''
            context.modules = [
              {
                name = "libpipewire-module-parametric-equalizer"
                args = {
                  node.name = "parametric-equalizer"
                  media.class = "Audio/Sink"
                  equalizer.filepath = "${EQPath}"
                  equalizer.description = "EQ Sink"
                }
              }
            ]
          '';
          ".config/pipewire/EQ.txt".source = ./parametric.txt;
        };
      };
    };
}
