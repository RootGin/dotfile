{ self, inputs, ... }:
{
  imports = [
    ./netorbit.nix  # ← add this
  ];

  flake.nixosModules.coreProgramsMonitoring = {
    imports = [
      self.nixosModules.coreProgramsMonitoringBtop
      self.nixosModules.coreProgramsMonitoringCava
      self.nixosModules.coreProgramsMonitoringFastfetch
      self.nixosModules.coreProgramsMonitoringVulnix
      self.nixosModules.coreProgramsMonitoringNetorbit
    ];
  };
}
