{
  config,
  lib,
  pkgs,
  ...
}:
let
  myAliases = import ./commonAliases.nix;
  username = config.my.user.username;
in
{
  home-manager.users.${username} = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      bashrcExtra = ''
        source ${pkgs.blesh}/share/blesh/ble.sh --noattach
      '';
      initExtra = lib.mkOrder 2000 ''
        if [[ ''${BLE_VERSION-} ]]; then
          ble-face -s auto_complete 'fg=242'
          ble-attach
        fi
      '';
    };

    programs.direnv.enableBashIntegration = true;
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        format =
          "$os"
          + "$username"
          + "[](bg:orange fg:red)"
          + "$directory"
          + "[](bg:yellow fg:orange)"
          + "$git_branch"
          + "$git_commit"
          + "$git_state"
          + "$git_status"
          + "[](fg:yellow bg:green)"
          + "$c"
          + "$rust"
          + "$golang"
          + "$nodejs"
          + "$bun"
          + "$php"
          + "$java"
          + "$kotlin"
          + "$haskell"
          + "$python"
          + "[](fg:green bg:cyan)"
          + "$conda"
          + "[](fg:cyan bg:purple)"
          + "$time"
          + "[](fg:purple)"
          + "$cmd_duration"
          + "$line_break"
          + "$character";

        # ---------------- OS + user (red) ----------------

        os = {
          disabled = false;
          style = "bg:red fg:base00";
          format = "[ $symbol]($style)";
          symbols = {
            Windows = "";
            Ubuntu = "";
            SUSE = "";
            Raspbian = "";
            Mint = "";
            Macos = "";
            Manjaro = "";
            Linux = "";
            Gentoo = "";
            Fedora = "";
            Alpine = "";
            Amazon = "";
            Android = "";
            AOSC = "";
            Arch = "";
            Artix = "";
            CentOS = "";
            Debian = "";
            Redhat = "";
            RedHatEnterprise = "";
            NixOS = "";
          };
        };

        username = {
          show_always = true;
          style_user = "bg:red fg:base00";
          style_root = "bg:red fg:base00 bold";
          format = "[ $user ]($style)";
        };

        # ---------------- Directory (orange) ----------------

        directory = {
          style = "bg:orange fg:base00";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            Documents = "󰈙 ";
            Downloads = " ";
            Music = "󰝚 ";
            Pictures = " ";
            Developer = "󰲋 ";
          };
        };

        # ---------------- Git (yellow) ----------------

        git_branch = {
          symbol = "";
          style = "bg:yellow fg:base00";
          format = "[ $symbol $branch ]($style)";
          truncation_length = 30;
          truncation_symbol = "…";
        };

        git_commit = {
          only_detached = true;
          commit_hash_length = 7;
          tag_disabled = false;
          tag_symbol = " ";
          style = "bg:yellow fg:base00";
          format = "[\\($hash$tag\\) ]($style)";
        };

        git_state = {
          style = "bg:yellow fg:red bold";
          format = "[\\[$state( $progress_current/$progress_total)\\] ]($style)";
          rebase = "REBASING";
          merge = "MERGING";
          revert = "REVERTING";
          cherry_pick = "CHERRY-PICKING";
          bisect = "BISECTING";
          am = "AM";
          am_or_rebase = "AM/REBASE";
        };

        git_status = {
          style = "bg:yellow fg:base00";
          format = "[($all_status$ahead_behind )]($style)";
          conflicted = "=\${count}";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          up_to_date = "✔";
          untracked = "?\${count}";
          stashed = "≡\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          renamed = "»\${count}";
          deleted = "✘\${count}";
        };

        # ---------------- Languages (green) ----------------

        nodejs = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        bun = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        c = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        java = {
          symbol = " ";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        kotlin = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        haskell = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version) ](fg:base00 bg:green)]($style)";
        };

        python = {
          symbol = "";
          style = "bg:green";
          format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:base00 bg:green)]($style)";
        };

        # ---------------- Conda (cyan) ----------------

        conda = {
          symbol = " ";
          style = "fg:base00 bg:cyan";
          format = "[$symbol$environment ]($style)";
          ignore_base = false;
        };

        # ---------------- Time (purple) ----------------

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:purple";
          format = "[[  $time ](fg:base00 bg:purple)]($style)";
        };

        # ---------------- After the bar ----------------

        cmd_duration = {
          min_time = 2000;
          format = " [took $duration](fg:bright-black)";
          disabled = false;
        };

        line_break = {
          disabled = false;
        };

        character = {
          disabled = false;
          success_symbol = "[❯](bold fg:green)";
          error_symbol = "[❯](bold fg:red)";
          vimcmd_symbol = "[❮](bold fg:green)";
          vimcmd_replace_one_symbol = "[❮](bold fg:purple)";
          vimcmd_replace_symbol = "[❮](bold fg:purple)";
          vimcmd_visual_symbol = "[❮](bold fg:yellow)";
        };
      }
      // lib.optionalAttrs (!config.my.desktop.enable) {
        palette = "ansi_fallback";
        palettes.ansi_fallback = {
          base00 = "black";
          orange = "yellow";
          bright-black = "bright-black";
        };
      };
    };
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
