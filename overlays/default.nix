self: super: {
  # Custom packages. Will be made available on all machines and used where
  # needed.
  anki-bin = super.pkgs.callPackage ../packages/anki-bin { };
  darknet = super.pkgs.callPackage ../packages/darknet { };
  plex = super.pkgs.callPackage ../packages/plex { };
  plexRaw = super.pkgs.callPackage ../packages/plex/raw.nix { };

  # override with newer version from nixpkgs-unstable
  tautulli = self.unstable.tautulli;

  # override with newer version from nixpkgs-unstable (home-manager related)
  chromium = self.unstable.chromium;
  discord = self.unstable.discord;
  firefox = self.unstable.firefox;
  neovim-unwrapped = self.unstable.neovim-unwrapped;
  obs-studio = self.unstable.obs-studio;
  signal-desktop = self.unstable.signal-desktop;
  spotify = self.unstable.spotify;
  sublime-merge = self.unstable.sublime-merge;
  sublime3 = self.unstable.sublime3;
  teamspeak_client = self.unstable.teamspeak_client;
  tdesktop = self.unstable.tdesktop;
  thunderbird-bin = self.unstable.thunderbird-bin;
  vscode = self.unstable.vscode;
  youtube-dl = self.unstable.youtube-dl;
  zoom-us = self.unstable.zoom-us;
}
