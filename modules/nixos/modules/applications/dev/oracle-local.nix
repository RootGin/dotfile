{ self, ... }:
{
  flake.nixosModules.applicationsDevOracleLocal =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.dev.oracleLocal;
      containerName = "oracle-free";
      dbPassword = "qlctkt#123";
      schemaDir = "/home/${config.userOptions.username}/Documents/Viettel/qlctkt/qlctkt-service/db";
    in
    {
      options.programs.dev.oracleLocal = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Local Oracle Free (FREEPDB1 + QLCTKT schema) via Podman, managed by systemd.";
        };
      };

      config = lib.mkIf (config.programs.dev.enable && cfg.enable) {
        virtualisation = {
          podman = {
            enable = true;
            dockerCompat = true;
          };
          oci-containers = {
            backend = "podman";
            containers.${containerName} = {
              image = "docker.io/gvenzl/oracle-free:23-slim";
              ports = [ "1521:1521" ];
              environment = {
                ORACLE_PASSWORD = dbPassword;
                APP_USER = "qlctkt";
                APP_USER_PASSWORD = dbPassword;
              };
              volumes = [
                "oracle-free-data:/opt/oracle/oradata"
                "${schemaDir}:/setup:ro"
              ];
            };
          };
        };

        systemd.services.oracle-qlctkt-init = {
          description = "Import qlctkt legacy schema into local Oracle FREEPDB1";
          after = [ "podman-${containerName}.service" ];
          requires = [ "podman-${containerName}.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -eu
            PODMAN=${pkgs.podman}/bin/podman
            CONNECT='qlctkt/${dbPassword}@//127.0.0.1:1521/FREEPDB1'

            for i in $(seq 1 60); do
              if echo "WHENEVER SQLERROR EXIT 1
            SELECT 'READY' FROM DUAL;
            EXIT;" | "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" 2>/dev/null | grep -q READY; then
                break
              fi
              if [ "$i" -eq 60 ]; then
                echo "oracle-qlctkt-init: DB never became ready" >&2
                exit 1
              fi
              sleep 1
            done

            TABLES=$(echo "SET HEADING OFF FEEDBACK OFF PAGESIZE 0
            SELECT COUNT(*) FROM USER_TABLES;
            EXIT;" | "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" | tr -d '[:space:]')
            if [ "$TABLES" -eq 0 ]; then
              echo "oracle-qlctkt-init: importing legacy-schema.sql..."
              "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" @/setup/legacy-schema.sql
            else
              echo "oracle-qlctkt-init: schema already present ($TABLES tables), skipping."
            fi
          '';
        };
      };
    };
}
