{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.rea;
  reaPkgs = pkgs.callPackage ./packages.nix {};
  # Qt 6.12's uic rejects template names in promoted widgets.
  # Give the default specialization a valid identifier without changing its type.
  cutter = pkgs.cutter.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        for ui in \
          src/dialogs/XrefsDialog.ui \
          src/widgets/BreakpointWidget.ui \
          src/widgets/FlagsWidget.ui \
          src/widgets/GlobalsWidget.ui \
          src/widgets/ListDockWidget.ui \
          src/widgets/SearchWidget.ui \
          src/widgets/StringsWidget.ui; do
          substituteInPlace "$ui" \
            --replace-fail 'AddressableItemList&lt;&gt;' 'DefaultAddressableItemList'
        done
        substituteInPlace src/widgets/AddressableItemList.h \
          --replace-fail '#endif // ADDRESSABLE_ITEM_LIST_H' \
            $'using DefaultAddressableItemList = AddressableItemList<>;\n\n#endif // ADDRESSABLE_ITEM_LIST_H'
      '';
  });
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.rea = {
      enable = mkEnableOption "the reverse-engineering toolchain REA drives (Ghidra, JADX, Apktool, Rizin, ...)";
    };
  };

  config = mkIf cfg.enable {
    # REA (https://github.com/morluto/rea) does not bundle or install these; it
    # discovers them on PATH (or through its REA_*_COMMAND overrides).
    environment.systemPackages = with pkgs; [
      # Native analysis engines.
      ghidra
      rizin
      cutter

      # Android: static APK analysis, resource decoding and on-device work.
      jadx
      apktool
      aapt
      apksigner
      android-tools
      frida-tools

      # Binary, debugger and format inspection.
      binutils # objdump, readelf, nm, strings
      gdb
      file
      dtc # device trees
      reaPkgs.wabt # WebAssembly; REA requires 1.0.42
      ilspycmd # .NET assemblies
      solc # EVM bytecode
      sigrok-cli # signal captures

      # Firmware inspection and extraction; prlimit comes from util-linux.
      binwalk
      unblob
      e2fsprogs # debugfs, an Unblob external extractor
      util-linux

      # Runtime network and packet capture.
      tshark # also provides capinfos
      tcpdump
      mitmproxy # mitmdump

      # REA's own runtime and its Linux process-ownership prerequisite.
      nodejs_26
      procps
    ];

    # REA accepts absolute tool paths (or exact versions) for several adapters
    # and defaults its prlimit helpers to /usr/bin/prlimit, which NixOS lacks.
    environment.sessionVariables = {
      REA_BINWALK_COMMAND = "${pkgs.binwalk}/bin/binwalk";
      REA_UNBLOB_COMMAND = "${pkgs.unblob}/bin/unblob";
      REA_SIGROK_COMMAND = "${pkgs.sigrok-cli}/bin/sigrok-cli";
      REA_TSHARK_COMMAND = "${pkgs.tshark}/bin/tshark";
      REA_CAPINFOS_COMMAND = "${pkgs.tshark}/bin/capinfos";

      REA_EVM_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_FIRMWARE_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_JAVASCRIPT_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_SIGROK_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";
      REA_TSHARK_PRLIMIT_COMMAND = "${pkgs.util-linux}/bin/prlimit";

      REA_JADX_MCP_JAR = "${reaPkgs.jadx-headless-mcp}/share/java/jadx-headless-mcp-0.7.1-all.jar";
      REA_PWNTOOLS_PYTHON = "${reaPkgs.pwntools-python}/bin/python3";
      REA_WABT_BIN_DIRECTORY = "${reaPkgs.wabt}/bin";
      REA_WAKARU_COMMAND = "${reaPkgs.wakaru}/bin/wakaru";
    };
  };
}
