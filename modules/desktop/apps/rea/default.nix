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
      wabt # WebAssembly
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
  };
}
