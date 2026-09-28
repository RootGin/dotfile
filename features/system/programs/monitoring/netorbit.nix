{ self, inputs, ... }:
{
  flake.nixosModules.coreProgramsMonitoringNetorbit =
    { pkgs, ... }:
    let
      netorbit = pkgs.python3Packages.buildPythonApplication {
        pname = "netorbit";
        version = "1.1.0";
        pyproject = true;
        src = pkgs.fetchFromGitHub {
          owner = "ZXCurban";
          repo = "NetOrbit";
          rev = "v1.1.0";
          sha256 = "sha256-JXStAxxPTj8AUj7PpiBiBpugIL0aoWygAYKpVnmFmyI=";
        };
        build-system = with pkgs.python3Packages; [
          setuptools
        ];
        propagatedBuildInputs = with pkgs.python3Packages; [
          scapy
          rich
          requests
        ];
      };
    in
    {
      environment.systemPackages = [
        netorbit
        pkgs.libpcap
      ];
    };
}
