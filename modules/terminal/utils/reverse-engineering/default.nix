{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.terminal.utils.reverse-engineering;

  # REA's adapters admit specific upstream profiles, not arbitrary newer tools.
  # Keep these overrides local so unrelated applications retain Nixpkgs versions.
  unicorn = pkgs.unicorn.overrideAttrs {
    version = "2.1.2";
    src = pkgs.fetchFromGitHub {
      owner = "unicorn-engine";
      repo = "unicorn";
      tag = "2.1.2";
      hash = "sha256-qA84xBztyWmt/rUExhhZMkQzvDPx0UE9MAIPG/Su3iE=";
    };
  };
  python = pkgs.python312.override {
    packageOverrides = final: prev: {
      pyelftools = prev.pyelftools.overridePythonAttrs {
        version = "0.33";
        src = pkgs.fetchFromGitHub {
          owner = "eliben";
          repo = "pyelftools";
          tag = "v0.33";
          hash = "sha256-NqF5A6PRl4uncwNS9j44fIV7ovlljiucvV2Msv0LK/w=";
        };
      };
      unicorn = prev.unicorn.override {inherit unicorn;};
    };
  };
  pwntoolsPython = python.withPackages (ps: [ps.pwntools]);
  wabt = pkgs.wabt.overrideAttrs {
    version = "1.0.42";
    src = pkgs.fetchFromGitHub {
      owner = "WebAssembly";
      repo = "wabt";
      tag = "1.0.42";
      fetchSubmodules = true;
      hash = "sha256-33XpYt42Jw2xfwBR64jVI3VYVIKD1YjND9SSI6CdkaM=";
    };
  };
  sigrok = pkgs.sigrok-cli.overrideAttrs {
    version = "0.7.2";
    src = pkgs.fetchzip {
      url = "https://sigrok.org/download/source/sigrok-cli/sigrok-cli-0.7.2.tar.gz";
      hash = "sha256-WpdEYFJF8pE3mUWXfuOlKEFeTqYfNu9MND9cXZLUZcI=";
    };
  };
  # The normal jadx package does not contain REA's headless MCP engine.
  jadxMcp = pkgs.fetchurl {
    url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar";
    hash = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
  };
in {
  imports = [./darlings.nix];

  options.tiebe.terminal.utils.reverse-engineering = {
    enable = mkEnableOption "Linux reverse-engineering tools for REA";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs_24 # REA CLI/MCP via npx; includes npm.
      procps # REA's Linux owned-process checks require procps ps.
      util-linux # prlimit for recorded captures and firmware.
      ghidra
      jdk21
      binutils
      gdb
      rizin
      jadx
      apktool
      android-tools
      binwalk
      unblob
      e2fsprogs # Firmware ext filesystem extractor (debugfs).
      mitmproxy
      wireshark-cli
      chromium
      wabt
      sigrok
    ];

    # Absolute paths also work when the MCP client has a minimal PATH.
    # Do not replace the user's general-purpose Python or Java selection.
    environment.sessionVariables = {
      GHIDRA_INSTALL_DIR = "${pkgs.ghidra}/lib/ghidra";
      REA_JADX_MCP_JAR = "${jadxMcp}";
      REA_PWNTOOLS_PYTHON = "${pwntoolsPython}/bin/python3";
      REA_WABT_BIN_DIRECTORY = "${wabt}/bin";
      REA_OBJDUMP_COMMAND = "${pkgs.binutils}/bin/objdump";
      REA_GDB_COMMAND = "${pkgs.gdb}/bin/gdb";
      REA_RIZIN_COMMAND = "${pkgs.rizin}/bin/rizin";
      REA_APKTOOL_COMMAND = "${pkgs.apktool}/bin/apktool";
      REA_BINWALK_COMMAND = "${pkgs.binwalk}/bin/binwalk";
      REA_UNBLOB_COMMAND = "${pkgs.unblob}/bin/unblob";
      REA_FIRMWARE_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_MITMDUMP_COMMAND = "${pkgs.mitmproxy}/bin/mitmdump";
      REA_TSHARK_COMMAND = "${pkgs.wireshark-cli}/bin/tshark";
      REA_CAPINFOS_COMMAND = "${pkgs.wireshark-cli}/bin/capinfos";
      REA_TSHARK_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_SIGROK_COMMAND = "${sigrok}/bin/sigrok-cli";
      REA_SIGROK_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
    };
  };
}
