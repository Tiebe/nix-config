{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.desktop.apps.opencode;
  evictCfg = config.tiebe.system.boot.evictDarlings;

  baseOpencodePackage = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default or null;

  opencodePackage =
    if baseOpencodePackage != null
    then
      baseOpencodePackage.overrideAttrs (oldAttrs: {
        # Workaround for https://github.com/anomalyco/opencode/issues/18447
        postFixup =
          (oldAttrs.postFixup or "")
          + lib.optionalString pkgs.stdenv.isLinux ''
            wrapProgram $out/bin/opencode \
              --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.cc.cc.lib}/lib
          '';
      })
    else null;

  desktopPackage = pkgs.opencode;
  # desktopPackage = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.desktop;

  # Determine config directory based on evict-darlings
  opencodeConfigDir =
    if evictCfg.enable
    then "${evictCfg.configDir}/opencode"
    else "/home/tiebe/.config/opencode";

  # Determine local/share directory based on evict-darlings
  opencodeLocalDir =
    if evictCfg.enable
    then "${evictCfg.configDir}/local/share/opencode"
    else "/home/tiebe/.local/share/opencode";
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.opencode = {
      enable = mkEnableOption "OpenCode";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.opencode
      pkgs.opencode-desktop
    ];

  systemd.services.opencode-litellm-proxy = {
    description = "OpenCode LiteLLM compatibility proxy";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";

      ExecStart = "${pkgs.nodejs}/bin/node ${./proxy.mjs}";

      Restart = "always";
      RestartSec = 3;
    };
  };



    home-manager.users.tiebe = {
      hmConfig,
      lib,
      ...
    }: {
      home.file = {
        "${opencodeConfigDir}/opencode.jsonc".source = ./config/opencode.jsonc;
        "${opencodeConfigDir}/oh-my-opencode.json".source = ./config/oh-my-opencode.json;
        "${opencodeConfigDir}/dcp.jsonc".source = ./config/dcp.jsonc;
      };

      # Merge API key into existing auth.json (preserving OAuth tokens)
      home.activation.mergeOpencodeAuthJson = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${opencodeLocalDir}"
        API_KEY="$(${pkgs.coreutils}/bin/cat ${config.age.secrets.litellmKey.path})"
        AUTH_FILE="${opencodeLocalDir}/auth.json"

        if [ -f "$AUTH_FILE" ]; then
          # Merge into existing file at top level
          $DRY_RUN_CMD ${pkgs.jq}/bin/jq --arg apiKey "$API_KEY" \
            '.anthropic = {type: "api", key: $apiKey} | ."litellm" = {type: "api", key: $apiKey}' \
            "$AUTH_FILE" > "$AUTH_FILE.tmp" && mv "$AUTH_FILE.tmp" "$AUTH_FILE"
        else
          # Create new file with top-level key
          $DRY_RUN_CMD ${pkgs.jq}/bin/jq -n --arg apiKey "$API_KEY" \
            '{anthropic: {type: "api", key: $apiKey}, "litellm": {type: "api", key: $apiKey}}' \
            > "$AUTH_FILE"
        fi
      '';
    };
  };
}
