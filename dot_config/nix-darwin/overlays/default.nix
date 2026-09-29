{
  # Export all overlays as a list
  allOverlays = [
    (import ./lsd.nix)
    (import ./recode.nix)
  ];
}
