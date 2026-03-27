{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.zsh;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # # Zsh history and Atuin sync state persistence
    # systemd.tmpfiles.rules = if evictCfg.enable then [
    #   # For evict darlings: ZDOTDIR is set to configDir/zsh via envExtra
    #   # History is stored in ZDOTDIR
    #   "L ${evictCfg.configDir}/zsh/.zsh_history - - - - /persist${evictCfg.configDir}/zsh/.zsh_history"
    #   # Atuin data is relative to actual home directory
    #   "L ${evictCfg.homeDir}/.cache/atuin - - - - /persist${evictCfg.homeDir}/.cache/atuin"
    #   "L ${evictCfg.homeDir}/.local/share/atuin - - - - /persist${evictCfg.homeDir}/.local/share/atuin"
    # ] else [
    #   # Standard erase darlings paths
    #   "L /home/tiebe/.zsh_history - - - - /persist/home/tiebe/.zsh_history"
    #   "L /home/tiebe/.cache/atuin - - - - /persist/home/tiebe/.cache/atuin"
    #   "L /home/tiebe/.local/share/atuin - - - - /persist/home/tiebe/.local/share/atuin"
    # ];

    home-manager.users.tiebe = {
      programs.zsh = mkIf (evictCfg.enable && cfg.enable) {
        dotDir = "${evictCfg.configDir}/zsh";

        # For evict darlings: Set ZDOTDIR early in zshenv
        envExtra = mkIf evictCfg.enable ''
          export ZDOTDIR="${evictCfg.configDir}/zsh"
          export HOME="${evictCfg.baseDir}"
        '';

        initContent = lib.mkAfter ''
          # Switch HOME to the actual home directory for user session
          export HOME="${evictCfg.homeDir}"
          # Navigate to home directory on interactive login
          if [[ -o interactive ]]; then
            cd ~ 2>/dev/null || true
          fi
        '';
      };
    };
  };
}
