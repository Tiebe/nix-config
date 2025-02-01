{
  config,
  pkgs,
  ...
}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      timeout = 0;
    };
  };
}
