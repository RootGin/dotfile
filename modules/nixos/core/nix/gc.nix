{
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
