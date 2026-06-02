{ self, inputs, ... }:
{
  flake.nixosModules.modulesSecurityAgenix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
      secretsDir = "${self.outPath}/secrets";

      hasSecret = name: builtins.pathExists "${secretsDir}/${name}.age";

      allSecretsExist = lib.all hasSecret [
        "deepseek-api-key"
        "qwen-api-key"
        "rootgin-password-hash"
      ];
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];

      options.security.agenix = {
        enable = lib.mkEnableOption "Enable agenix secret management";

        secretsAvailable = lib.mkOption {
          type = lib.types.bool;
          default = allSecretsExist;
          readOnly = true;
          description = "Whether all encrypted secret files exist in the secrets directory.";
        };
      };

      config = lib.mkIf config.security.agenix.enable {
        age = lib.mkIf allSecretsExist {
          identityPaths = [
            "/home/${username}/.config/agenix/age.key"
          ];

          secrets = {
            "deepseek-api-key" = { };

            "qwen-api-key" = { };

            "rootgin-password-hash" = {
              owner = "root";
              group = config.users.users.${username}.group;
              mode = "0440";
            };
          };
        };

        environment.systemPackages = with pkgs; [
          age
          openssl
          inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
