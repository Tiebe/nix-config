{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  cairo,
  dbus,
  fontconfig,
  gdk-pixbuf,
  glib,
  glib-networking,
  gst_all_1,
  gtk3,
  libayatana-appindicator,
  libsoup_3,
  libx11,
  libxcb,
  libxi,
  libxkbcommon,
  openssl,
  systemdLibs,
  webkitgtk_4_1,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opendeck";
  version = "2.14.0";

  src = fetchurl {
    url = "https://github.com/nekename/OpenDeck/releases/download/v${finalAttrs.version}/opendeck_${finalAttrs.version}_amd64.deb";
    hash = "sha256-tBOCcRMOop3GrO2D/X4wGBplmTUdj9L6ye2aeLq+plY=";
  };

  unpackCmd = "dpkg-deb -x $curSrc source";
  sourceRoot = "source";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    dbus
    fontconfig
    gdk-pixbuf
    glib
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    libsoup_3
    libxcb
    libxkbcommon
    openssl
    systemdLibs
    webkitgtk_4_1
  ];

  # dlopen'd at runtime, so invisible to autoPatchelf: the tray icon needs
  # appindicator and input simulation needs Xlib.
  runtimeDependencies = [
    libayatana-appindicator
    libx11
    libxi
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    # Tauri resolves its resource directory as $out/bin/../lib/opendeck, so the
    # bundled starter pack plugin must keep its relative position.
    cp -r usr/bin usr/lib usr/share $out/
    install -Dm444 etc/udev/rules.d/40-streamdeck.rules -t $out/etc/udev/rules.d

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Software for using stream controller devices such as the Elgato Stream Deck";
    homepage = "https://github.com/nekename/OpenDeck";
    changelog = "https://github.com/nekename/OpenDeck/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "opendeck";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
