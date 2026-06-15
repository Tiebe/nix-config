{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.steam;
  evictCfg = config.tiebe.system.boot.evictDarlings;

  gamescope-kbm = pkgs.gamescope.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        (pkgs.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/ValveSoftware/gamescope/pull/1897.diff";
          hash = "sha256-qe8BKKj97aaugjE5Ug1RO2uU7+iDdC5JpOFkGYLjV6Q=";
        })
      ];
  });

  protonhax = pkgs.stdenv.mkDerivation rec {
    pname = "protonhax";
    version = "1.0.5";

    src = pkgs.fetchFromGitHub {
      owner = "jcnils";
      repo = pname;
      rev = version;
      sha256 = "sha256-5G4MCWuaF/adSc9kpW/4oDWFFRpviTKMXYAuT2sFf9w=";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp protonhax $out/bin
    '';

    postFixup = ''
      sed -i '1s/#!/#!${lib.escape ["/"] (lib.getExe pkgs.steam-run)} /' $out/bin/protonhax
    '';

    meta = {
      description = "Tool to help running other programs (i.e. Cheat Engine) inside Steam's proton";
      homepage = "https://github.com/jcnils/protonhax";
      license = lib.licenses.bsd3;
      maintainers = [lib.maintainers.pneg];
      mainProgram = "protonhax";
    };
  };
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.desktop.apps.steam = {
      enable = mkEnableOption "Steam";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = let
      homeRoot =
        if evictCfg.enable
        then evictCfg.configDir
        else "/home/tiebe";
      steamDataRoot = "${homeRoot}/.local/share/Steam";
      compatPrefix = "${steamDataRoot}/steamapps/compatdata/230410/pfx";
    in {
      xdg.desktopEntries.alecaframe = {
        name = "AlecaFrame";
        exec = ''protonhax run 230410 "${compatPrefix}/drive_c/users/steamuser/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Overwolf/AlecaFrame.lnk"'';
        type = "Application";
        startupNotify = true;
        icon = "${compatPrefix}/drive_c/users/steamuser/AppData/Local/Overwolf/AppShortcutIcons/afmcagbpgggkpdkokjhjkllpegnadmkignlonpjm.ico";
        terminal = false;
        settings = {
          "Name[en_US]" = "AlecaFrame";
          TerminalOptions = "";
        };
      };
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
      protontricks.enable = true;
      # For evict darlings: override HOME to config directory
      package =
        if evictCfg.enable
        then
          pkgs.steam.override {
            extraEnv = {
              HOME = evictCfg.configDir;
            };
          }
        else pkgs.steam;
    };

    environment.systemPackages = with pkgs; [gamescope gamemode bubblewrap protonhax];
  };
}
