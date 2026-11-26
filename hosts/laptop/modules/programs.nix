{ config, pkgs, ... }:
let
  wrapNvidiaOffload =
    pkg: binName:
    (pkgs.symlinkJoin {
      name = "${pkg.pname or pkg.name}-nvidia-offload";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${binName} \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia \
          --set __VK_LAYER_NV_optimus NVIDIA_only
        if [ -L "$out/share" ]; then
          share_dir="$(readlink -f "$out/share")"
          rm "$out/share"
          mkdir -p "$out/share"
          for item in "$share_dir"/*; do
            ln -s "$item" "$out/share/"
          done
        fi
        if [ -L "$out/share/applications" ]; then
          apps_dir="$(readlink -f "$out/share/applications")"
          rm "$out/share/applications"
          mkdir -p "$out/share/applications"
          cp -r "$apps_dir"/. "$out/share/applications/"
          chmod -R u+w "$out/share/applications"
        fi
        for f in $out/share/applications/*.desktop; do
          if [ -e "$f" ]; then
            if [ -L "$f" ]; then
              cp --remove-destination "$(readlink -f "$f")" "$f"
              chmod u+w "$f"
            fi
            substituteInPlace "$f" --replace-quiet "${pkg}/bin/" "$out/bin/"
          fi
        done
      '';
      meta = pkg.meta or { };
    })
    // {
      override = args: wrapNvidiaOffload (pkg.override args) binName;
    };

  remotionRender = pkgs.writeShellScriptBin "remotion-render" ''
    export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
    exec nvidia-offload npx remotion render --gl=angle-egl --hardware-acceleration=if-possible "$@"
  '';
in
{
  config.my.programs = {
    browsing = {
      chromium = {
        enable = true;
        package = pkgs.brave;
      };
      zen = {
        enable = true;
      };
    };
    ai = {
      enable = true;
      opencode = {
        enable = true;
      };
      "agent-skills" = {
        enable = true;
        ui-ux-pro-max.enable = true;
        mattpocock = {
          enable = true;
          engineering = true;
          productivity = true;
        };
      };
    };
    dev = {
      oracleLocal.enable = true;
    };
  };

  config.programs.nixcord.discord.installPackage = false;

  config.home-manager.users.${config.my.user.username}.programs.zen-browser.env = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  config.environment.systemPackages = [
    (wrapNvidiaOffload config.programs.nixcord.finalPackage.discord "Discord")
    remotionRender
  ];

  config.programs.bash.interactiveShellInit = ''
    npm() {
      if [ "$#" -ge 2 ] && [ "$1" = "run" ] && { [ "$2" = "render" ] || [ "$2" = "dev" ]; }; then
        if [ -f /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json ]; then
          __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json \
            nvidia-offload npm "$@"
        else
          nvidia-offload npm "$@"
        fi
      else
        command npm "$@"
      fi
    }
  '';
}
