{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    services.gvfs.enable = true;

    # Unmount stale gvfsd-fuse mounts (both $XDG_RUNTIME_DIR/gvfs and ~/.gvfs fallback)
    # on service start/stop so rebuilds or restarts don't leave dead mounts ("Connection refused").
    systemd.user.services.gvfs-daemon = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        ExecStartPre = [
          "-${pkgs.fuse3}/bin/fusermount3 -uzq %h/.gvfs"
          "-${pkgs.fuse3}/bin/fusermount3 -uzq %t/gvfs"
        ];
        ExecStopPost = [
          "-${pkgs.fuse3}/bin/fusermount3 -uzq %h/.gvfs"
          "-${pkgs.fuse3}/bin/fusermount3 -uzq %t/gvfs"
        ];
      };
    };
  };
}
