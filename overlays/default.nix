# This file defines overlays
{inputs, ...}: {
  modifications = final: prev: {
    ragenix = prev.ragenix.override {
      plugins = [final.age-plugin-yubikey];
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
          Exec=BambuStudio %U
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
