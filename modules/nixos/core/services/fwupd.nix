{ lib, ... }:
{
  services.fwupd.enable = lib.mkDefault false;
}
