# Upstream's flake (`inputs.omp`) builds omp from source via bun2nix +
# rust-overlay, which currently fails against very recent nixpkgs-unstable
# (rust-overlay's `mk-aggregated.nix` references the now-removed
# `stdenv.isLinux`, even against omp's own pinned nixpkgs). Use the prebuilt
# release binary instead — this matches what was already manually installed
# on this machine. `programs.nix-ld.enable` (modules/base/nix) resolves its
# dynamic glibc dependencies at runtime, so no patchelf step is needed.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "omp";
  version = "17.3.0";

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v17.3.0/omp-linux-x64";
    hash = "sha256-KH8HNm8piW7x40VCPat5uCqNwMFZM4PiDf3WKp3S55k=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
    runHook postInstall
  '';

  meta = {
    description = "Oh My Pi (omp) — AI coding agent for the terminal";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "omp";
  };
}
