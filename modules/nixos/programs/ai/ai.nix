{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.my.user) username;
  cfg = config.my.programs.ai;
  dshCfg = cfg.deepseek-harness;
  reaCfg = cfg.rea;
  opencodeCfg = cfg.opencode;

  reaPkg = pkgs.callPackage ./rea.nix { };

  dshPlugins =
    lib.optionals dshCfg.dshmarket.enable [
      "dshmarket"
    ]
    ++ dshCfg.plugins;

  opencodeJson = {
    "$schema" = "https://opencode.ai/config.json";
    autoupdate = false;

    mcp = {
      mcp-nixos = {
        type = "local";
        enabled = true;
        command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
      };
      playwright = {
        type = "local";
        enabled = true;
        command = [
          "npx"
          "-y"
          "@playwright/mcp@latest"
        ];
      };
    }
    // opencodeCfg.mcpServers;
  };

in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        antigravity-cli
        antigravity-hub
        antigravity-ide
      ])
      ++ lib.optionals cfg.deepseek-harness.enable [
        pkgs.deepseek-harness
      ]
      ++ lib.optionals reaCfg.enable [
        reaPkg
      ]
      ++ lib.optionals opencodeCfg.enable [
        pkgs.opencode
      ];
    home-manager.users.${username} = lib.mkMerge [
      (lib.mkIf opencodeCfg.enable {
        xdg.configFile."opencode/opencode.json" = {
          force = true;
          text = builtins.toJSON opencodeJson;
        };
      })
      (lib.mkIf (dshCfg.enable && dshPlugins != [ ]) {
        home.activation.deepseekHarnessPlugins =
          inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
            ''
              if [[ -z "''${DRY_RUN:-}" ]]; then
                profile=${lib.escapeShellArg dshCfg.profile}
                pkgJson="$HOME/.dsh/profiles/$profile/package.json"
                for pkg in ${lib.concatMapStringsSep " " lib.escapeShellArg dshPlugins}; do
                  pkgName="$pkg"
                  if [[ "$pkgName" =~ ^(@?[^@]+)@.+$ ]]; then
                    pkgName="''${BASH_REMATCH[1]}"
                  fi
                  if ! ${pkgs.jq}/bin/jq -e --arg pkg "$pkgName" \
                    '(.dependencies[$pkg] != null) or ((.dsh.profile.bundles // []) | index($pkg) != null)' \
                    "$pkgJson" >/dev/null 2>&1; then
                    echo "Installing DeepSeek Harness plugin '$pkg' into profile '$profile'..."
                    if ! ${pkgs.deepseek-harness}/bin/dsh plugin --profile "$profile" add "$pkg"; then
                      echo "warning: failed to install DeepSeek Harness plugin '$pkg' (offline or registry error)" >&2
                    fi
                  fi
                done
              fi
            '';
      })
      (lib.mkIf (reaCfg.enable && dshCfg.enable && reaCfg.dsh.enable) {
        home.activation.deepseekHarnessReaMcp =
          inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
            ''
              if [[ -z "''${DRY_RUN:-}" ]]; then
                patchFile="$HOME/.dsh/cordis.patch.yml"
                reaScript="${reaPkg}/lib/node_modules/rea-agents/scripts/rea.mjs"
                if [[ ! -f "$patchFile" ]] || ! ${pkgs.gnugrep}/bin/grep -qF "$reaScript" "$patchFile"; then
                  echo "Configuring REA MCP server for DeepSeek Harness..."
                  if ! ${reaPkg}/bin/rea setup --client dsh --yes; then
                    echo "warning: failed to configure REA MCP server for DeepSeek Harness" >&2
                  fi
                fi
              fi
            '';
      })
    ];
  };
}
