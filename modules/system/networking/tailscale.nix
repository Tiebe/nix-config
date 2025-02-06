{
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    #useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale.path;
  };

  networking.firewall.checkReversePath = false;
}
