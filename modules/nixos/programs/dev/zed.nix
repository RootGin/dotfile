{
  config,
  lib,
  ...
}:
let
  username = config.my.user.username;
in
{
  config = lib.mkIf config.my.programs.dev.enable {
    home-manager.users.${username} = {
      programs.zed-editor = {
        enable = true;
        # Exports EDITOR/VISUAL as `zeditor -w` now that neovim is gone.
        defaultEditor = true;
      };
    };
  };
}
