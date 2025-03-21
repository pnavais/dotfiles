final: prev: {
  bitwarden-cli = prev.bitwarden-cli.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ])
      ++ [ prev.llvmPackages_18.stdenv.cc ];
    stdenv = prev.llvmPackages_18.stdenv;
  });
}
