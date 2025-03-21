{
  # Export all overlays as a list
  allOverlays = [
    (import ./alacritty.nix)
    (import ./obsidian.nix)
    (import ./bitwarden-cli.nix)
    # Add more overlays here
  ];
}
