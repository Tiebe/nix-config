{
  lib,
  meson,
  ninja,
  pkg-config,
  gettext,
  fetchFromGitHub,
  python3,
  wrapGAppsHook3,
  gtk3,
  glib,
  desktop-file-utils,
  appstream-glib,
  adwaita-icon-theme,
  gobject-introspection,
  librsvg,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "piper";
  version = "0-unstable-2026-08-12";

  format = "other";

  src = fetchFromGitHub {
    owner = "libratbag";
    repo = "piper";
    rev = "5d3c8845b55643595ccb8029dfa5c7a2fb079e77";
    hash = "sha256-oGa0NXgoiVYadCAB5cnQYrjh3KIVWhTxsSYaB4TVZSA=";
  };

  nativeBuildInputs = [meson ninja gettext pkg-config wrapGAppsHook3 desktop-file-utils appstream-glib gobject-introspection];
  buildInputs = [
    gtk3
    glib
    adwaita-icon-theme
    python3
    librsvg
  ];
  propagatedBuildInputs = with python3.pkgs; [lxml evdev pygobject3];

  mesonFlags = [
    "-Druntime-dependency-checks=false"
    # "-Dtests=false"
  ];

  postPatch = ''
    chmod +x meson_install.sh # patchShebangs requires executable file
    patchShebangs meson_install.sh data/generate-piper-gresource.xml.py
  '';

  meta = with lib; {
    description = "GTK frontend for ratbagd mouse config daemon";
    mainProgram = "piper";
    homepage = "https://github.com/libratbag/piper";
    license = licenses.gpl2;
    maintainers = with maintainers; [mvnetbiz];
    platforms = platforms.linux;
  };
}
