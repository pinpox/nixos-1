inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  mayniklas = {
    drone-gen = super.pkgs.callPackage ../packages/drone-gen { };
    mtu-check = super.pkgs.callPackage ../packages/mtu-check { };
    s3uploader = super.pkgs.callPackage ../packages/s3uploader { };
    update-input = super.pkgs.callPackage ../packages/update-input { };
    vs-fix = super.pkgs.callPackage ../packages/vs-fix { };
  };
}
