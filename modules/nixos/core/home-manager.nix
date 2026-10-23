# The single place the Home Manager NixOS module is imported.
{ inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
}
