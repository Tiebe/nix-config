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

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = true;
  };

  home.file = {
    ".gnupg/gpg.conf".source = ./gpg.conf;
    ".gnupg/scdaemon.conf".text = "disable-ccid";
    #".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  };
}
