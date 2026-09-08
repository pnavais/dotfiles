final: prev: {
  lsd = prev.lsd.overrideAttrs (old: {
    # Custom --date formats are strftime strings; use non-localized formatting so
    # fractional seconds keep POSIX dots (see lsd-rs/lsd PR #820 regression).
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace src/meta/date.rs \
          --replace 'DateFlag::Formatted(format) => val.format_localized(format, locale).to_string(),' \
                    'DateFlag::Formatted(format) => val.format(format).to_string(),'
      '';
  });
}
