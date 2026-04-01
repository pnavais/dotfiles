{
  # Export all overlays as a list
  allOverlays = [
    (import ./obsidian.nix)
    (import ./bitwarden-cli.nix)
      (import ./mise.nix)
    # Add more overlays here
  ];
}
