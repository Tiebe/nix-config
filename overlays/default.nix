# This file defines overlays
{inputs, ...}: {
  modifications = final: prev: {
    ragenix = prev.ragenix.override {
      plugins = [final.age-plugin-yubikey];
    };

    bambu-studio = prev.appimageTools.wrapType2 rec {
      name = "BambuStudio";
      pname = "bambu-studio";
      version = "02.07.00.55";

      src = prev.fetchurl {
        url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu-22.04-v${version}-20260514170313.AppImage";
        sha256 = "1rsbwh9d5a35gmifilad4vsxkfdsnh81gbhm59d3y66sxa5ml95f";
      };

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
  };
}
