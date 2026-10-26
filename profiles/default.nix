# Profiles should not be imported together via default.nix.
# Instead, host configurations should import their specific profile:
#   - ../../profiles/workstation.nix (for desktop/workstation environments)
#   - ../../profiles/server.nix      (for headless/server environments)
{ ... }:
{ }
