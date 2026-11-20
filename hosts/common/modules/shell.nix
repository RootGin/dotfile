{ config, ... }:
{
  config.my.shell = {
    # Keep zsh installed on desktop so anything referencing /run/current-system/sw/bin/zsh keeps working.
    zsh.enable = config.my.desktop.enable;
    fish.enable = true;
  };
}
