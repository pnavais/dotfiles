# Upstream already uses _7zz (the old undmg→_7zz swap is obsolete).
# Obsidian 1.13.4's DMG nests the app under "Obsidian <ver>-universal/", so
# sourceRoot = "Obsidian.app" fails. Mirror nixpkgs#548462 until unstable
# picks up dea0d9eeca494734e596f3f4a813324d6af41265 (or later).
self: super: {
  obsidian = super.obsidian.overrideAttrs (oldAttrs: {
    sourceRoot = null;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/{Applications,bin}
      cp -R Obsidian.app $out/Applications
      makeWrapper $out/Applications/Obsidian.app/Contents/MacOS/Obsidian $out/bin/obsidian
      makeWrapper $out/Applications/Obsidian.app/Contents/MacOS/obsidian-cli $out/bin/obsidian-cli
      runHook postInstall
    '';
  });
}
