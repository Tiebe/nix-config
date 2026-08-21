{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  wrapGAppsHook3,
  unzip,
  glib-networking,
  gtk3,
}: let
  pname = "profit-taker-analytics";
  version = "1.0.0";

  protocolHandler = makeDesktopItem {
    name = "pta-protocol";
    desktopName = "Profit Taker Analyzer";
    exec = "profit_taker_analyzer %u";
    noDisplay = true;
    mimeTypes = ["x-scheme-handler/pta"];
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/Basiiii/Profit-Taker-Analytics/releases/download/v${version}/LINUX_PTA_v${version}.zip";
      hash = "sha256-yzqDcuqUghlQRs9q7sRAe9rhXGBI+1F36vHNp1gm+J8=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
      wrapGAppsHook3
      unzip
    ];

    buildInputs = [
      glib-networking
      gtk3
      stdenv.cc.cc.lib
    ];

    dontUnpack = true;
    dontBuild = true;

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        desktopName = "Profit Taker Analytics";
        comment = "Analyze Profit Taker mission times and statistics";
        exec = "profit_taker_analyzer";
        icon = pname;
        categories = [
          "Game"
          "Utility"
        ];
      })
      protocolHandler
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p extracted $out/libexec/${pname} $out/bin
      unzip -q $src -d extracted
      cp -r extracted/bundle/. $out/libexec/${pname}/

      makeWrapper \
        $out/libexec/${pname}/profit_taker_analyzer \
        $out/bin/profit_taker_analyzer \
        --prefix LD_LIBRARY_PATH : $out/libexec/${pname}/lib

      install -Dm644 \
        $out/libexec/${pname}/data/flutter_assets/assets/AppIcon.png \
        $out/share/icons/hicolor/192x192/apps/${pname}.png

      runHook postInstall
    '';

    meta = {
      description = "Warframe Profit Taker mission timer and statistics analyzer";
      homepage = "https://github.com/Basiiii/Profit-Taker-Analytics";
      license = lib.licenses.unfree;
      mainProgram = "profit_taker_analyzer";
      platforms = ["x86_64-linux"];
    };
  }
