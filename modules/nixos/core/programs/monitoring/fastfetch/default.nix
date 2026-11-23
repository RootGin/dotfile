{
  config,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
  hasStylix = config.my.desktop.enable;
  colors = config.lib.stylix.colors.withHashtag;

  logoColor = if hasStylix then colors.base08 else "red";
  keysColor = if hasStylix then colors.base04 else "bright_black";
  outputColor = if hasStylix then colors.base05 else "white";
  separatorColor = if hasStylix then colors.base00 else "black";

  fastfetchConfig = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

    logo = {
      padding = {
        top = 1;
        right = 4;
        left = 2;
      };
      type = "kitty";
      color = {
        "1" = logoColor;
      };
    };

    display = {
      separator = " ";
      color = {
        keys = keysColor;
        output = outputColor;
        separator = separatorColor;
      };
      key = {
        width = 12;
      };
      bar = {
        char = {
          left = "[";
          right = "]";
          body = "─";
        };
        width = 16;
        border = {
          left = "[";
          right = "]";
        };
      };
      percent = {
        type = 0;
      };
      disableLinewrap = true;
    };

    modules = [
      {
        type = "title";
        key = "◍ SESSION";
        format = "{user-name}@{host-name}";
        keyColor = "red";
      }
      {
        type = "command";
        key = "⊙ INSTALLED";
        keyColor = "red";
        text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo \"$days_difference days ago\"";
      }
      {
        type = "uptime";
        key = "△ UPTIME";
        keyColor = "red";
      }
      "break"
      {
        type = "os";
        key = "◆ OS";
        keyColor = "blue";
      }
      {
        type = "kernel";
        key = "⊡ KERNEL";
        keyColor = "blue";
      }
      {
        type = "wm";
        key = "▦ WM";
        keyColor = "blue";
      }
      "break"
      {
        type = "host";
        key = "⬢ HOST";
        keyColor = "green";
      }
      {
        type = "cpu";
        key = "⚙ CPU";
        showPeCoreCount = true;
        keyColor = "green";
      }
      {
        type = "gpu";
        key = "▣ GPU";
        keyColor = "green";
      }
      {
        type = "disk";
        key = "◔ DISK";
        keyColor = "green";
      }
      {
        type = "memory";
        key = "𝍖 MEMORY";
        keyColor = "green";
      }
      "break"
      {
        type = "packages";
        key = "▪ PACKAGES";
        keyColor = "yellow";
      }
      {
        type = "initsystem";
        key = "⊛ INIT";
        keyColor = "yellow";
      }
      {
        type = "terminal";
        key = "▯ TERMINAL";
        keyColor = "yellow";
      }
      {
        type = "shell";
        key = "≻ SHELL";
        keyColor = "yellow";
      }
      "break"
      {
        type = "colors";
        paddingLeft = 2;
        symbol = "square";
      }
    ];
  };
in
{
  environment.systemPackages = with pkgs; [ fastfetch ];

  home-manager.users.${username} = _: {
    home.file = {
      ".config/fastfetch/config.jsonc".text = builtins.toJSON fastfetchConfig;
      ".config/fastfetch/nixos.png".source = ./nixos.png;
    };
  };
}
