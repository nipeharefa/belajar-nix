{ pkgs, lib, ... }:
{
    users.nix.configureBuildUsers = true;

    nix = {
    binaryCaches = [
        "https://cache.nixos.org/"
    ];

    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    useDaemon = true;

    trustedUsers = [
      "@admin"
    ];

    # Enable experimental nix command and flakes
    # package = pkgs.nixUnstable;
    extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
    ''
    + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };
}