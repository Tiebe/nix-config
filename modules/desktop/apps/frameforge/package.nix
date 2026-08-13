{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  cargo-tauri,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  pkg-config,
  clang,
  llvmPackages,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook3,
  libsoup_3,
  gtk3,
  tesseract,
  leptonica,
  dbus,
  xdotool,
  libxcb,
  nix-update-script,
}: let
  # The Linux build's `build.rs` shells out to `scripts/fetch-tessdata.sh` to
  # download the Tesseract English model it bundles as a resource. That script
  # skips its own network fetch when the destination already carries the
  # pinned checksum, so prefetching the same file through Nix (with network
  # access sandboxed builds don't otherwise have) and dropping it in place
  # ahead of the build satisfies the check without patching build.rs.
  tessdata-eng = fetchurl {
    url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata/c2b2e0df86272ce11be323f23f96cf656565ed41/eng.traineddata";
    hash = "sha256-2qDJfWUcGfujsl6BMXzWl+mQjIIICQyUw5BTgcI/wEc=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "frameforge";
    version = "3.2.0-linux.1";

    src = fetchFromGitHub {
      owner = "Lyrex";
      repo = "FrameForge-Linux";
      tag = "v${finalAttrs.version}";
      hash = "sha256-TP1dlgHMjKA+rOkSqdUxA6Vp4braRGsuIU8wLE5PJhA=";
    };

    postPatch = ''
      mkdir -p src-tauri/tessdata
      install -Dm444 ${tessdata-eng} src-tauri/tessdata/eng.traineddata
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-61kESgDxUFjqMzKwk3k7QO/Jg1QlVZPc/OFosuxFLPY=";
    };

    cargoHash = "sha256-T2Ac/V1szESqM1FoiKElCRmH8v/YvFcDymGc5n7AvYQ=";

    nativeBuildInputs = [
      cargo-tauri.hook
      pkg-config
      clang
      wrapGAppsHook3
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    buildInputs = [
      openssl
      libsoup_3
      glib-networking
      gtk3
      webkitgtk_4_1
      tesseract
      leptonica
      dbus
      xdotool
      libxcb
    ];

    # tesseract-sys / leptonica-sys use bindgen
    env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

    cargoRoot = "src-tauri";
    buildAndTestSubdir = finalAttrs.cargoRoot;

    # Tests require network access, X11 and a running Warframe process
    doCheck = false;

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Linux-compatible Warframe companion: inventory, market prices, trading, timers, relic overlay and riven analysis";
      mainProgram = "warframe-companion";
      homepage = "https://github.com/Lyrex/FrameForge-Linux";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  })
