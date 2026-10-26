{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.dev.oracleLocal;
  containerName = "oracle-free";
  username = config.my.user.username;
in
{
  options.my.programs.dev.oracleLocal = {
    enable = lib.mkEnableOption "Local Oracle Free (FREEPDB1) via Podman, managed by systemd";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/oracle-local/data";
      description = "Host directory or volume for Oracle database data (mounted to /opt/oracle/oradata).";
    };

    schemaDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/var/lib/oracle-local/schema";
      description = "Host directory containing schema SQL files to mount into container /setup.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/var/lib/oracle-local/oracle.env";
      description = "Path to environment file containing container credentials (e.g. ORACLE_PASSWORD, APP_USER, APP_USER_PASSWORD).";
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional path to separate file containing database password for schema initialization.";
    };

    appUser = lib.mkOption {
      type = lib.types.str;
      default = "qlctkt";
      description = "Application database user name for schema initialization.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start the Oracle database container automatically on boot. Default false to conserve RAM and tasks.";
    };
  };

  config = lib.mkIf (config.my.programs.dev.enable && cfg.enable) {
    # Ensure /var/lib directories exist with correct permissions before podman starts.
    # Oracle container runs internally as UID 54321 (oracle:dba).
    systemd.tmpfiles.rules = [
      "d /var/lib/oracle-local 0755 root root -"
      "d ${cfg.dataDir} 0750 54321 54321 -"
    ]
    ++ lib.optional (cfg.schemaDir != null) "d ${cfg.schemaDir} 0755 root root -";

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };
      oci-containers = {
        backend = "podman";
        containers.${containerName} = {
          image = "docker.io/gvenzl/oracle-free:23-slim";
          autoStart = cfg.autoStart;
          ports = [ "1521:1521" ];
          environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          volumes = [
            "${cfg.dataDir}:/opt/oracle/oradata"
          ]
          ++ lib.optional (cfg.schemaDir != null) "${cfg.schemaDir}:/setup:ro";
        };
      };
    };

    # Initialize env file and populate schema if empty
    systemd.services."podman-${containerName}" = {
      preStart = lib.mkBefore ''
        mkdir -p "${cfg.dataDir}"
        chown -R 54321:54321 "${cfg.dataDir}"
        chmod 0750 "${cfg.dataDir}"

        ${lib.optionalString (cfg.schemaDir != null) ''
          mkdir -p "${cfg.schemaDir}"
          chmod 0755 "${cfg.schemaDir}"
          # If schema directory is empty and user has legacy local Viettel SQL files, copy them over
          if [ -z "$(ls -A "${cfg.schemaDir}" 2>/dev/null)" ] && [ -d "/home/${username}/Documents/Viettel/qlctkt/qlctkt-service/db" ]; then
            cp -r /home/${username}/Documents/Viettel/qlctkt/qlctkt-service/db/* "${cfg.schemaDir}/" 2>/dev/null || true
          fi
        ''}

        ${lib.optionalString (cfg.environmentFile != null) ''
                    if [ ! -s "${cfg.environmentFile}" ]; then
                      cat << 'EOF' > "${cfg.environmentFile}"
          # Oracle Free Container Environment Variables (Local Dev)
          ORACLE_PASSWORD=qlctkt#123
          APP_USER=qlctkt
          APP_USER_PASSWORD=qlctkt#123
          EOF
                      chmod 0600 "${cfg.environmentFile}"
                    fi
        ''}
      '';
    };

    systemd.services.oracle-schema-init = lib.mkIf (cfg.schemaDir != null) {
      description = "Import schema into local Oracle FREEPDB1";
      after = [ "podman-${containerName}.service" ];
      requires = [ "podman-${containerName}.service" ];
      wantedBy = lib.mkIf cfg.autoStart [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -eu
        PODMAN=${pkgs.podman}/bin/podman

        if [ ! -d "${cfg.schemaDir}" ] || [ -z "$(ls -A "${cfg.schemaDir}" 2>/dev/null)" ]; then
          echo "oracle-schema-init: No schema files found in ${cfg.schemaDir}, skipping."
          exit 0
        fi

        DB_PASSWORD=""
        APP_USER="${cfg.appUser}"

        ${lib.optionalString (cfg.passwordFile != null) ''
          if [ -f "${cfg.passwordFile}" ]; then
            DB_PASSWORD=$(cat "${cfg.passwordFile}")
          fi
        ''}

        ${lib.optionalString (cfg.environmentFile != null) ''
          if [ -z "$DB_PASSWORD" ] && [ -f "${cfg.environmentFile}" ]; then
            DB_PASSWORD=$(grep -E '^(APP_USER_PASSWORD|ORACLE_PASSWORD)=' "${cfg.environmentFile}" | head -n1 | cut -d= -f2- || true)
            PARSED_USER=$(grep -E '^APP_USER=' "${cfg.environmentFile}" | head -n1 | cut -d= -f2- || true)
            [ -n "$PARSED_USER" ] && APP_USER="$PARSED_USER"
          fi
        ''}

        if [ -z "$DB_PASSWORD" ]; then
          echo "oracle-schema-init: Could not determine DB password from environmentFile or passwordFile, skipping."
          exit 0
        fi

        CONNECT="$APP_USER/$DB_PASSWORD@//127.0.0.1:1521/FREEPDB1"

        echo "oracle-schema-init: Waiting for database FREEPDB1 to become ready..."
        for i in $(seq 1 60); do
          if echo "WHENEVER SQLERROR EXIT 1
        SELECT 'READY' FROM DUAL;
        EXIT;" | "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" 2>/dev/null | grep -q READY; then
            break
          fi
          if [ "$i" -eq 60 ]; then
            echo "oracle-schema-init: DB never became ready after 60s" >&2
            exit 1
          fi
          sleep 2
        done

        TABLES=$(echo "SET HEADING OFF FEEDBACK OFF PAGESIZE 0
        SELECT COUNT(*) FROM USER_TABLES;
        EXIT;" | "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" 2>/dev/null | tr -d '[:space:]' || echo "0")

        if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
          if [ -f "${cfg.schemaDir}/legacy-schema.sql" ]; then
            echo "oracle-schema-init: importing legacy-schema.sql..."
            "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" @/setup/legacy-schema.sql
          elif [ -f "${cfg.schemaDir}/init.sql" ]; then
            echo "oracle-schema-init: importing init.sql..."
            "$PODMAN" exec -i ${containerName} sqlplus -S "$CONNECT" @/setup/init.sql
          fi
        else
          echo "oracle-schema-init: schema already present ($TABLES tables), skipping."
        fi
      '';
    };
  };
}
