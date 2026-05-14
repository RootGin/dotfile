{ self, ... }:
{
  flake.nixosModules.applicationsAi = {
    imports = [
      self.nixosModules.applicationsAiOptions
      self.nixosModules.applicationsAiConfig
      self.nixosModules.applicationsAiClaudeCode
      self.nixosModules.applicationsAiAgentSkills
    ];
  };
}
