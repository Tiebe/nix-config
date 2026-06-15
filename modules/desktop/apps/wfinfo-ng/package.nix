{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  cmake,
  clang,
  llvmPackages,
  tesseract,
  leptonica,
  openssl,
  fontconfig,
  libGL,
  libxkbcommon,
  wayland,
  curl,
  jq,
  xorg,
}: let
  runtimeLibs = [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXtst
    xorg.libxcb
  ];
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "wfinfo-ng";
    version = "0-unstable-2c6fbe6";

    src = fetchFromGitHub {
      owner = "knoellle";
      repo = "wfinfo-ng";
      rev = "2c6fbe6a2be160b6996857f0e72f339fad5273d3";
      hash = "sha256-CvgJAwYz2/4ivPd4jw5zXdToiRmjJI9Yq6OzVahgQ94=";
    };

    cargoHash = "sha256-qz4hKQP9+FcsmboHsEbR+Z19aWD65Ytj8iQVyYphQYA=";

    nativeBuildInputs = [
      pkg-config
      cmake
      clang
      makeWrapper
    ];

    buildInputs =
      [
        tesseract
        leptonica
        openssl
        fontconfig
      ]
      ++ runtimeLibs;

    # tesseract-sys / leptonica-sys use bindgen
    env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

    # freetype-sys bundles freetype with cmake_minimum_required < 3.5,
    # which modern cmake rejects without this policy override
    env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

    # The reward-screen helper binary only
    cargoBuildFlags = ["--bin" "wfinfo"];

    # Tests require network access and screen capture
    doCheck = false;

    postInstall = ''
      wrapProgram $out/bin/wfinfo \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
        --prefix PATH : "${lib.makeBinPath [curl jq]}" \
        --set-default TESSDATA_PREFIX "${tesseract}/share/tessdata"

      # Ship the database update helper alongside the binary
      install -Dm755 update.sh $out/bin/wfinfo-update
    '';

    meta = {
      description = "Linux-compatible WFinfo: analyze Warframe relic reward screens for platinum value";
      mainProgram = "wfinfo";
      homepage = "https://github.com/knoellle/wfinfo-ng";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  })
