{ lib, meson, ninja, pkg-config, gettext, fetchFromGitHub, python3
, wrapGAppsHook3, gtk3, glib, desktop-file-utils, appstream-glib, adwaita-icon-theme
, gobject-introspection, librsvg }:

python3.pkgs.buildPythonApplication rec {
  pname = "piper";
  version = "104ee170c1028f9d2fac1859dc6dea72efc0648f";

  format = "other";

  src = fetchFromGitHub {
    owner  = "libratbag";
    repo   = "piper";
    rev    = "192df857d44ec5c314aa59701a1c74940339b513";
    hash   = "sha256-IxXa1vvvRbrxl0khChJxW+fhp1dJi+HtFlJXUU4VKYw=";
  };

  nativeBuildInputs = [ meson ninja gettext pkg-config wrapGAppsHook3 desktop-file-utils appstream-glib gobject-introspection ];
  buildInputs = [
    gtk3 glib adwaita-icon-theme python3 librsvg
  ];
  propagatedBuildInputs = with python3.pkgs; [ lxml evdev pygobject3 ];

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
    homepage    = "https://github.com/libratbag/piper";
    license     = licenses.gpl2;
    maintainers = with maintainers; [ mvnetbiz ];
    platforms   = platforms.linux;
  };
}