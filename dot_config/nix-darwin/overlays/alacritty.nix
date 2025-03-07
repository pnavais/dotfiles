final: prev: {
  alacritty = prev.alacritty.overrideAttrs (oldAttrs: rec {
    # Keep the same version as the original package
    inherit (oldAttrs) version;

    # Add the custom crossfont source
    crossfontSrc = prev.fetchFromGitHub {
      owner = "alacritty";
      repo = "crossfont";
      rev = "v0.8.0";
      sha256 = "sha256-UheUJm4J/JMzLQlW6Ab6WruFLm6K6eTvJikY8pSDtpk=";
    };

    # Fetch the external patch for alacritty
    alacrittyPatch = prev.fetchurl {
      url =
        "https://raw.githubusercontent.com/pnavais/dotfiles/main/patches/alacritty.patch";
      sha256 = "19ac2jxrmww13x44mfcy0xhsxnr2grlcwfdgd333ab4c6xpp6i10";
    };

    # Add the external patch to the existing patches (if any)
    patches = (oldAttrs.patches or [ ]) ++ [ alacrittyPatch ];

    # Fetch the external patch for crossfont
    crossfontPatch = prev.fetchurl {
      url =
        "https://raw.githubusercontent.com/pnavais/dotfiles/main/patches/crossfont.patch";
      sha256 = "1g056g8k7bgaxzgs0ns7078s9n1d94cxf45wyj3nykvjrw2pmmvj";
    };

    # Create a derivation for the patched crossfont
    patchedCrossfont = prev.stdenv.mkDerivation {
      name = "patched-crossfont";
      src = crossfontSrc;

      nativeBuildInputs = [ prev.patch ];

      phases = [ "unpackPhase" "patchPhase" "installPhase" ];

      patchPhase = ''
        patch -p1 < ${crossfontPatch}
      '';

      installPhase = ''
        cp -r . $out
      '';
    };

    # Now set up the build process for alacritty to use our patched crossfont
    preBuild = ''
      ${oldAttrs.preBuild or ""}

      # Create the parent directory for crossfont
      mkdir -p ../crossfont

      # Copy the patched crossfont to the parent directory
      cp -r ${patchedCrossfont}/* ../crossfont/
    '';
  });
}
