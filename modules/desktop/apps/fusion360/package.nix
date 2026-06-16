{
  lib,
  stdenv,
  makeWrapper,
  installerSrc,
  gawk,
  cabextract,
  coreutils,
  curl,
  lsb-release,
  mesa-demos,
  p7zip,
  polkit,
  samba,
  spacenavd,
  wget,
  xdg-utils,
  bc,
  xorg,
  mokutil,
  wineWowPackages,
  wineWow64Packages,
  winetricks,
  gettext,
}:
stdenv.mkDerivation rec {
  pname = "fusion360-installer";
  version = "2.0.4-alpha";

  src = installerSrc;

  nativeBuildInputs = [makeWrapper];

  buildInputs = [
    gawk
    cabextract
    coreutils
    curl
    lsb-release
    mesa-demos
    p7zip
    polkit
    samba
    spacenavd
    wget
    xdg-utils
    bc
    xorg.xrandr
    mokutil
    wineWow64Packages.stable
    winetricks
    gettext
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/fusion360
    mkdir -p $out/share/applications

    # Copy the original installation script
    cp ${installerSrc}/files/setup/autodesk_fusion_installer_x86-64.sh $out/share/fusion360/autodesk_fusion_installer_x86-64.sh
    chmod +x $out/share/fusion360/autodesk_fusion_installer_x86-64.sh

    # Install the headless installer wrapper (backend)
    substitute ${./fusion360-installer-headless.sh} $out/bin/fusion360-install \
      --subst-var-by bin_path "${lib.makeBinPath buildInputs}" \
      --subst-var-by installer "$out/share/fusion360/autodesk_fusion_installer_x86-64.sh" \
      --subst-var-by version "${version}" \
      --subst-var-by installer_hash "${builtins.hashString "sha256" (builtins.readFile "${installerSrc}/files/setup/autodesk_fusion_installer_x86-64.sh")}"
    chmod +x $out/bin/fusion360-install

    # Install the runner (backend)
    substitute ${./fusion360-run.sh} $out/bin/fusion360-run \
      --subst-var-by bin_path "${lib.makeBinPath buildInputs}"
    chmod +x $out/bin/fusion360-run

    # Install the unified CLI (main entry point)
    substitute ${./fusion-cli.sh} $out/bin/fusion \
      --subst-var-by out "$out" \
      --subst-var-by bin_path "${lib.makeBinPath buildInputs}"
    chmod +x $out/bin/fusion

    # Create the adskidmgr URL scheme handler desktop file
    cat > $out/share/applications/adskidmgr-opener.desktop << EOF
    [Desktop Entry]
    Type=Application
    Name=Autodesk Identity Manager Scheme Handler
    Exec=sh -c 'env WINEPREFIX="\$HOME/.autodesk_fusion/wineprefixes/default" ${wineWowPackages.stable}/bin/wine "\$(find \$HOME/.autodesk_fusion/wineprefixes/default/ -name "AdskIdentityManager.exe" | head -1)" "%u"'
    StartupNotify=false
    MimeType=x-scheme-handler/adskidmgr;
    NoDisplay=true
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "Autodesk Fusion 360 on Linux via Wine with unified CLI";
    homepage = "https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    maintainers = [];
    mainProgram = "fusion";
  };
}
