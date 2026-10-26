{
  config,
  lib,
  ...
}:
let
  cfg = config.my.security.hardening;
in
{
  options.my.security.hardening = {
    enable = lib.mkEnableOption "system security and network hardening";

    fail2ban = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fail2ban intrusion prevention for services like SSH.";
      };
    };

    kernel = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable kernel sysctl network hardening parameters.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure firewall is explicitly enabled
    networking.firewall.enable = lib.mkDefault true;

    # Intrusion prevention: automatically ban hosts with repeated authentication failures
    services.fail2ban = lib.mkIf cfg.fail2ban.enable {
      enable = true;
      maxretry = 3;
      bantime = "24h";
      bantime-increment.enable = true;
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
    };

    # Kernel & Network sysctl hardening
    boot.kernel.sysctl = lib.mkIf cfg.kernel.enable {
      # TCP SYN flood mitigation
      "net.ipv4.tcp_syncookies" = 1;

      # Reverse-path filtering (loose mode = 2 to stay compatible with NetBird/ZeroTier mesh VPNs)
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;

      # Do not accept or send ICMP redirects (mitigate MITM route alterations)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;

      # Ignore broadcast ICMP echoes and bogus error responses
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

      # RFC 1337 TIME-WAIT assassination hazard protection
      "net.ipv4.tcp_rfc1337" = 1;
    };
  };
}
