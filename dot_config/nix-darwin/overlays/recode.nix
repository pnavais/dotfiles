# macOS libiconv lists some aliases (e.g. WINDOWS-874) under more than one
# charset group. recode 3.7.16 treats that as a fatal init error and fails
# its check phase on aarch64-darwin. Keep the first binding instead.
final: prev: {
  recode = prev.recode.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./recode-darwin-iconv-aliases.patch
    ];
  });
}
