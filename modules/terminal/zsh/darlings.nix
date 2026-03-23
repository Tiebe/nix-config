{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.zsh;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Zsh history and Atuin sync state persistence
    systemd.tmpfiles.rules = if evictCfg.enable then [
      # For evict darlings: ZDOTDIR is set to configDir/zsh via envExtra
      # History is stored in ZDOTDIR
      "L ${evictCfg.configDir}/zsh/.zsh_history - - - - /persist${evictCfg.configDir}/zsh/.zsh_history"
      # Atuin data is relative to actual home directory
      "L ${evictCfg.homeDir}/.cache/atuin - - - - /persist${evictCfg.homeDir}/.cache/atuin"
      "L ${evictCfg.homeDir}/.local/share/atuin - - - - /persist${evictCfg.homeDir}/.local/share/atuin"
    ] else [
      # Standard erase darlings paths
      "L /home/tiebe/.zsh_history - - - - /persist/home/tiebe/.zsh_history"
      "L /home/tiebe/.cache/atuin - - - - /persist/home/tiebe/.cache/atuin"
      "L /home/tiebe/.local/share/atuin - - - - /persist/home/tiebe/.local/share/atuin"
    ];
  };
}
