{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.utils.basic;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;

  sshDir =
    if evictCfg.enable
    then "${evictCfg.configDir}/ssh"
    else "/home/tiebe/.ssh";
  persistSshDir =
    if evictCfg.enable
    then "/persist${evictCfg.configDir}/ssh"
    else "/persist/home/tiebe/.ssh";
in {
  config = mkIf (darlings.enable && cfg.enable) {
    programs.ssh = mkIf (evictCfg.enable && cfg.enable) {
      extraConfig = ''
        Host *
          IdentityFile ${evictCfg.configDir}/ssh/id_ed25519
          IdentitiesOnly yes
      '';
    };

    # Persist SSH known_hosts file
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      home.file."${sshDir}/known_hosts".source =
        config.lib.file.mkOutOfStoreSymlink "${persistSshDir}/known_hosts";
    };
  };
}
