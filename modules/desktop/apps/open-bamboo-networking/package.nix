{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  curl,
  openssl,
  python3,
  gnused,
  coreutils,
  gnugrep,
  findutils,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "open-bamboo-networking";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/ClusterM/open-bamboo-networking/releases/download/v${finalAttrs.version}/obn-linux-x64.tar.gz";
    hash = "sha256-G/k6C9jX02MT4+I7RZVU9U6QEXxs/UALtlqscjo4IYs=";
  };

  # The bundled *.so files (all ABI version subdirectories under lib/) are
  # dynamically linked; liblive555.so is static and needs no patching.
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    curl
    openssl
    stdenv.cc.cc.lib
  ];

  # Only the *.so payload should be scanned/patched; install.sh is a shell
  # script and must not be touched by autoPatchelfHook.
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/open-bamboo-networking
    cp -r lib $out/share/open-bamboo-networking/
    install -Dm755 install.sh $out/share/open-bamboo-networking/install.sh

    makeWrapper $out/share/open-bamboo-networking/install.sh $out/bin/open-bamboo-networking-install \
      --prefix PATH : ${lib.makeBinPath [python3 gnused coreutils gnugrep findutils]}

    runHook postInstall
  '';

  meta = {
    description = "Open-source drop-in replacement for Bambu Studio's proprietary bambu_networking plugin";
    homepage = "https://github.com/ClusterM/open-bamboo-networking";
    changelog = "https://github.com/ClusterM/open-bamboo-networking/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "open-bamboo-networking-install";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
