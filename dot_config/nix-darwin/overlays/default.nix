{
  # Export all overlays as a list
  allOverlays = [
    (import ./obsidian.nix)
    (import ./mise.nix)
    # Add more overlays here
  ];
}
