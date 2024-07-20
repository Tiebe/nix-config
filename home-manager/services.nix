{
  config,
  pkgs,
  ...
}: {
  systemd.user.startServices = "sd-switch";

  services.lorri.enable = true;
  services.arrpc.enable = true;

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "tiebe.groosman@gmail.com";
        password_cmd = "bash -c 'cat /run/secrets/spotify/password'";
        device_name = builtins.getEnv "HOSTNAME";
        device_type = "computer";
      };
    };
  };
}
