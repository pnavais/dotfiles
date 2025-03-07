{
  # Export all overlays as a list
  allOverlays = [
    (import ./alacritty.nix)
    (import ./obsidian.nix)
    # Add more overlays here
  ];
}
