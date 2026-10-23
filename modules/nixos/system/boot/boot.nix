{ self, ... }:
{
  flake.nixosModules.coreBootBoot =
    { pkgs, ... }:
    let
      # Preview a GRUB 2.x theme in KVM/QEMU without rebooting.
      # Not in nixpkgs; pure-stdlib Python package, so package it here.
      grub2-theme-preview = pkgs.python3Packages.buildPythonApplication rec {
        pname = "grub2-theme-preview";
        version = "2.10.0";
        format = "setuptools";

        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/source/g/grub2-theme-preview/grub2_theme_preview-${version}.tar.gz";
          hash = "sha256-DGsGPzkBlasMtATT54neFpfWxzSILWji3NO0RNz9ma8=";
        };

        nativeBuildInputs = [ pkgs.makeWrapper ];

        # Point it at the NixOS paths for GRUB platform files and OVMF,
        # and put the runtime helpers it shells out to on PATH.
        postFixup = ''
          wrapProgram $out/bin/grub2-theme-preview \
            --prefix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.grub2_efi
                pkgs.mtools
                pkgs.xorriso
                pkgs.qemu
              ]
            } \
            --set G2TP_GRUB_LIB ${pkgs.grub2_efi}/lib/grub \
            --set G2TP_OVMF_IMAGE ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd
        '';

        meta.mainProgram = "grub2-theme-preview";
      };
    in
    {
      boot = {
        loader = {
          timeout = 30;
          systemd-boot.enable = false;

          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };

          grub = {
            enable = true;
            device = "nodev";
            useOSProber = true;
            efiSupport = true;
            theme = ./grub-themes/loq-15arp10e;
          };
        };

        initrd.systemd.enable = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };

      environment.systemPackages = [ grub2-theme-preview ];

      stylix.targets.grub.enable = false;
    };
}
