{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.zerogravity;

  zerogravity-unwrapped = pkgs.rustPlatform.buildRustPackage rec {
    pname = "zerogravity";
    version = "1.1.5";

    src = inputs.zerogravity-src;

    cargoHash = "sha256-mZqz9ZKvJiWepTrbSW7ufdWVUNgb/O7DLZSANN5xx3U=";

    # The upstream .cargo/config.toml hardcodes clang + mold + sccache
    # which are not needed (or available) in a Nix build.
    postPatch = ''
      rm -f .cargo/config.toml
    '';

    nativeBuildInputs = with pkgs; [
      pkg-config
      cmake
      go
      perl
      clang
      git
      rustPlatform.bindgenHook
    ];

    buildInputs = with pkgs; [
      openssl
    ];

    meta = with lib; {
      description = "OpenAI-compatible proxy for Google Antigravity";
      homepage = "https://github.com/NikkeTryHard/zerogravity";
      license = licenses.mit;
      mainProgram = "zerogravity";
    };
  };

  # Runtime dependencies that must be in PATH when zerogravity runs:
  # - gcc: compiles dns_redirect.so (LD_PRELOAD DNS hook) at runtime
  # - sudo: spawns the LS binary as zerogravity-ls user for UID isolation
  # - coreutils/findutils: env, id, etc. used by the binary
  # - iptables: UID-scoped traffic redirect
  runtimeDeps = with pkgs; [gcc sudo coreutils findutils iptables];

  zerogravity = pkgs.symlinkJoin {
    name = "zerogravity-wrapped";
    paths = [zerogravity-unwrapped];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      for bin in zerogravity zg; do
        wrapProgram $out/bin/$bin \
          --prefix PATH : ${lib.makeBinPath runtimeDeps}
      done
    '';
  };
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.zerogravity = {
      enable = mkEnableOption "ZeroGravity proxy";

      user = mkOption {
        type = types.str;
        default = "tiebe";
        description = "User that runs the ZeroGravity service and gets sudoers access.";
      };

      lsBinaryPath = mkOption {
        type = types.str;
        default = "${pkgs.antigravity}/lib/antigravity/resources/app/extensions/antigravity/bin/language_server_linux_x64";
        description = ''
          Path to the Antigravity language server binary.
          If empty, zerogravity will use its built-in default
          (/usr/share/antigravity/resources/app/extensions/antigravity/bin/language_server_linux_x64).
          Set this to the actual path on your system.
        '';
        example = "/home/tiebe/.local/share/antigravity/language_server_linux_x64";
      };
    };
  };

  config = mkIf cfg.enable {
    # Make binaries available system-wide (zerogravity + zg)
    environment.systemPackages = [
      zerogravity
      pkgs.iptables
      pkgs.curl
      pkgs.jq
      pkgs.antigravity
    ];

    # System user for UID-scoped iptables isolation
    users.users.zerogravity-ls = {
      isSystemUser = true;
      group = "zerogravity-ls";
      shell = "/run/current-system/sw/bin/nologin";
      description = "ZeroGravity LS isolation user";
    };

    users.groups.zerogravity-ls = {};

    # Sudoers: allow the configured user to run commands as zerogravity-ls
    security.sudo.extraRules = [
      {
        users = [cfg.user];
        runAs = "zerogravity-ls";
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Data directory (sticky-bit 1777)
    systemd.tmpfiles.rules = [
      "d /tmp/zerogravity-standalone 1777 root root -"
      "d /home/${cfg.user}/.config/zerogravity 0755 ${cfg.user} users -"
    ];

    # Systemd user service for the configured user
    systemd.user.services.zerogravity = {
      description = "ZeroGravity Proxy";
      after = ["network.target"];
      wantedBy = ["default.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${zerogravity}/bin/zerogravity --headless";
        Restart = "on-failure";
        RestartSec = 3;
        StandardOutput = "journal";
        StandardError = "journal";
      };

      environment =
        {
          RUST_LOG = "info";
        }
        // lib.optionalAttrs (cfg.lsBinaryPath != "") {
          ZEROGRAVITY_LS_PATH = cfg.lsBinaryPath;
        };
    };
  };
}
