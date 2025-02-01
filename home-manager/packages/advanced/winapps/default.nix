{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."winapps/winapps.conf".text = lib.generators.toINIWithGlobalSection { } {
    globalSection = {
      RDP_USER = "Docker";
      RDP_PASS = "WinApps";
      RDP_DOMAIN = "";

      RDP_IP = "127.0.0.1";
      WAFLAVOR = "docker";
      RDP_SCALE = "100";

      RDP_FLAGS = "\"/cert:tofu /sound /microphone\"";
      MULTIMON = "false";
      DEBUG = "true";

      AUTOPAUSE = "on";
      AUTOPAUSE_TIME = "300";
      FREERDP_COMMAND = "";
    };
    sections = {};
  };  
}
