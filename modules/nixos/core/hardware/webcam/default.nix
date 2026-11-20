{
  config,
  lib,
  pkgs,
  ...
}:
let
  webcam-conf = pkgs.writeShellApplication {
    name = "fix-webcam";
    runtimeInputs = [ pkgs.v4l-utils ];
    text = ''
      # UGREEN 2K Webcam
      shopt -s nullglob nocasematch
      for sysdev in /sys/class/video4linux/video*; do
        name=$(<"$sysdev/name")
        if [[ "$name" == *ugreen* ]]; then
          dev="/dev/''${sysdev##*/}"
          if v4l2-ctl -d "$dev" --get-fmt-video >/dev/null 2>&1; then
            v4l2-ctl -d "$dev" \
              --set-ctrl=brightness=-30 \
              --set-ctrl=contrast=41 \
              --set-ctrl=saturation=80 \
              --set-ctrl=white_balance_automatic=0 \
              --set-fmt-video=width=2560,height=1440,pixelformat=MJPG
          fi
        fi
      done
    '';
  };
in
{
  config = lib.mkIf config.my.desktop.enable {
    environment.systemPackages = with pkgs; [
      v4l-utils
    ];

    systemd.user.services.webcam-conf = {
      description = "Overwrite webcam default settings";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${webcam-conf}/bin/fix-webcam";
        RemainAfterExit = true;
        StandardOutput = "journal";
      };
    };

    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
    ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };
}
