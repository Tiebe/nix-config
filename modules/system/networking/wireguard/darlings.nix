{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.networking.wireguard;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # No persistence needed for wireguard - NetworkManager stores profiles in /etc
    # which is already persisted via the main darlings module
  };
}
