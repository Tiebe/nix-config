# This file defines overlays
{inputs, ...}: {
  modifications = final: prev: let
    small = import inputs.nixpkgs-small {
      inherit (final.stdenv.hostPlatform) system;
      inherit (final) config;
    };
  in {
    ragenix = prev.ragenix.override {
      plugins = [final.age-plugin-yubikey];
    };

    claude-code = small.claude-code;

    remanager = let
      version = "1.6.0";
      src = prev.fetchurl {
        url = "https://github.com/rmitchellscott/reManager/releases/download/v${version}/reManager-linux-amd64.tar.gz";
        sha256 = "sha256-HMbdPSurVqP6r6XN14IQRVXcvuI8spWbsP8CjmqMdqA=";
      };
      desktopFile = prev.fetchurl {
        url = "https://raw.githubusercontent.com/rmitchellscott/reManager/v${version}/flatpak/io.scottlabs.reManager.desktop";
        sha256 = "sha256-0vYDmBeJU37EpdIjUQWWoo3oejeP01N+Oa6VNAgzrP0=";
      };
      metainfo = prev.fetchurl {
        url = "https://raw.githubusercontent.com/rmitchellscott/reManager/v${version}/flatpak/io.scottlabs.reManager.metainfo.xml";
        sha256 = "sha256-oeryw01Nzai/0x5SC3S4KRQET80eMXzW6fJaW0sutDs=";
      };
      icon = prev.fetchurl {
        url = "https://raw.githubusercontent.com/rmitchellscott/reManager/v${version}/assets/icon.svg";
        sha256 = "sha256-rgDsiOStQoR1Wu72+9xsmvWr4yYlvxUS5RulagvtQOw=";
      };
    in
      prev.stdenvNoCC.mkDerivation {
        inherit version;
        pname = "remanager";
        src = src;

        nativeBuildInputs = [prev.gnutar prev.makeWrapper prev.installShellFiles];

        dontConfigure = true;
        dontBuild = true;
        dontUnpack = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          tar -xzf $src -C $out/bin
          chmod +x $out/bin/reManager
          install -Dm644 ${desktopFile} $out/share/applications/io.scottlabs.reManager.desktop
          install -Dm644 ${metainfo} $out/share/metainfo/io.scottlabs.reManager.metainfo.xml
          install -Dm644 ${icon} $out/share/icons/hicolor/scalable/apps/io.scottlabs.reManager.svg
          runHook postInstall
        '';

        postFixup = ''
          wrapProgram $out/bin/reManager \
            --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [
              prev.glib
              prev.gtk3
              prev.gdk-pixbuf
              prev.libsoup_3
              prev.webkitgtk_4_1
              prev.gst_all_1.gst-plugins-base
              prev.gst_all_1.gst-plugins-good
            ]}
        '';

        meta = {
          description = "Multi-platform desktop app for managing mods on reMarkable tablets";
          homepage = "https://github.com/rmitchellscott/reManager";
          license = prev.lib.licenses.gpl3Plus;
          platforms = ["x86_64-linux"];
          mainProgram = "reManager";
        };
      };

    bambu-studio = let
      version = "02.07.00.55";
      src = prev.fetchurl {
        url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu-22.04-v${version}-20260514170313.AppImage";
        sha256 = "1rsbwh9d5a35gmifilad4vsxkfdsnh81gbhm59d3y66sxa5ml95f";
      };
      extracted = prev.appimageTools.extractType2 {
        inherit version src;
        pname = "bambu-studio";
      };
      wrapped = prev.appimageTools.wrapType2 {
        name = "BambuStudio";
        pname = "bambu-studio";
        inherit version src;

        profile = ''
          export SSL_CERT_FILE="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
          export GIO_MODULE_DIR="${prev.glib-networking}/lib/gio/modules/"
        '';

        extraPkgs = pkgs:
          with pkgs; [
            cacert
            glib
            glib-networking
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            webkitgtk_4_1
          ];
      };
    in
      prev.symlinkJoin {
        name = "bambu-studio-${version}";
        paths = [wrapped];
        postBuild = ''
          mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
          cp ${extracted}/BambuStudio.png $out/share/icons/hicolor/256x256/apps/BambuStudio.png
          cat > $out/share/applications/BambuStudio.desktop << EOF
          [Desktop Entry]
          Name=BambuStudio
          GenericName=3D Printing Software
          Comment=A cutting-edge, feature-rich slicing software.
          Exec=bambu-studio %U
          Icon=BambuStudio
          Terminal=false
          Type=Application
          Categories=Graphics;3DGraphics;Engineering;
          MimeType=model/stl;model/3mf;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;x-scheme-handler/bambustudio;x-scheme-handler/bambustudioopen;
          Keywords=3D;Printing;Slicer;slice;3D;printer;convert;gcode;stl;obj;amf;SLA
          StartupNotify=false
          StartupWMClass=bambu-studio
          EOF
        '';
      };
  };
}
