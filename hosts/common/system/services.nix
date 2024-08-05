{
  config,
  pkgs,
  ...
}: {
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  services.tailscale = {
    enable = true;
    #useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale.path;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
