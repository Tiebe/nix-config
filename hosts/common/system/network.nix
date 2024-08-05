{
  config,
  pkgs,
  ...
}: {
  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "100.100.100.100"
    "8.8.8.8"
    "1.1.1.1"
    "2001:4860:4860::8888"
    "2606:4700:4700::1111"
  ];
  networking.firewall.checkReversePath = false;
}
