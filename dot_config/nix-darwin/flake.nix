{
  description = "Artax nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = { self, nix-darwin, mac-app-util, nix-homebrew, homebrew-core
    , homebrew-cask, homebrew-bundle, ... }:
    let
      configuration = { pkgs, config, ... }: {

        # Allow non opensource apps
        nixpkgs.config.allowUnfree = true;

        # Import all custom overlays
        nixpkgs.overlays = (import ./overlays).allOverlays;

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          pkgs.alacritty
          pkgs.antidote
          pkgs.ast-grep
          pkgs.bat
          pkgs.bitwarden-cli
          pkgs.boxes
          pkgs.chezmoi
          pkgs.choose
          pkgs.cowsay
          pkgs.coreutils
          pkgs.curl
          pkgs.delta
          pkgs.diskus
          pkgs.dust
          pkgs.eza
          pkgs.fd
          pkgs.figlet
          pkgs.file
          pkgs.findutils
          pkgs.fortune
          pkgs.fzf
          pkgs.gawk
          pkgs.git
          pkgs.gnused
          pkgs.gnutar
          pkgs.gzip
          pkgs.htop
          pkgs.hyperfine
          pkgs.iconv
          pkgs.jq
          pkgs.just
          pkgs.kitty
          pkgs.lazydocker
          pkgs.lazygit
          pkgs.lsd
          pkgs.macchina
          pkgs.mas
          pkgs.mise
          pkgs.neovim
          pkgs.nil
          pkgs.nixfmt-classic
          pkgs.nixd
          pkgs.obsidian
          pkgs.openssh
          pkgs.openssl
          pkgs.pastel
          pkgs.procps
          pkgs.procs
          pkgs.ripgrep
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.silver-searcher
          pkgs.starship
          pkgs.tldr
          pkgs.tmux
          pkgs.toilet
          pkgs.vim
          pkgs.wget
          pkgs.yazi
          pkgs.zoxide
        ];

        environment.variables = {
          ANTIDOTE_SRC = "${pkgs.antidote}/share/antidote";
        };

        # Brew packages
        homebrew = {
          taps = builtins.attrNames config.nix-homebrew.taps;
          enable = true;
          casks = [
            "alfred"
            "arc"
            "bartender"
            "brave-browser"
            "doppler"
            "firefox"
            "ghostty"
            "google-chrome"
            "hammerspoon"
            "iina"
            "iterm2"
            "jetbrains-toolbox"
            "keka"
            "monitorcontrol"
            "orbstack"
            "rectangle"
            "rustdesk"
            "spotify"
            "warp"
            "zed"
          ];
          # Mac App Store apps
          masApps = {
            "Bitwarden" = 1352778147;
            "Edison Mail" = 1489591003;
            "Sleeve" = 1606145041;
            "Things 3" = 904280696;
          };
          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
          global = { brewfile = true; };
        };

        # Mac customizations
        system.defaults = {
          NSGlobalDomain.KeyRepeat = 2;
          NSGlobalDomain.InitialKeyRepeat = 15;
        };

        # Fonts to be installed
        fonts.packages = [
          pkgs.nerd-fonts.caskaydia-cove
          pkgs.nerd-fonts.caskaydia-mono
          pkgs.nerd-fonts.code-new-roman
          pkgs.nerd-fonts.departure-mono
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.nerd-fonts.iosevka
          pkgs.nerd-fonts.lilex
          pkgs.nerd-fonts.martian-mono
          pkgs.nerd-fonts.meslo-lg
          pkgs.nerd-fonts.monaspace

          # Specific Noto fonts
          (pkgs.noto-fonts.override {
            variants = [ "NotoSansMono" "NotoSansSymbols" "NotoSansSymbols2" ];
          })
        ];

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#artax
      darwinConfigurations."artax" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "pnavais";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          mac-app-util.darwinModules.default
        ];
      };
    };
}
