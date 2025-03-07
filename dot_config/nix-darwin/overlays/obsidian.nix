self: super: {
  obsidian = super.obsidian.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (with self; [ _7zz ]) ++ (builtins.filter (x: x != super.undmg) oldAttrs.nativeBuildInputs);
  });
}
