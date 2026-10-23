{ self, inputs, ... }:
{
  flake.nixosModules.coreProgramsUtils = {
    imports = [
      self.nixosModules.coreProgramsUtilsAppimage
      self.nixosModules.coreProgramsUtilsLocalsend
      self.nixosModules.coreProgramsUtilsRclone
      self.nixosModules.coreProgramsUtilsRipgrep
    ];
  };
}
