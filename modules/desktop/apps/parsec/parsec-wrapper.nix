{ pkgs, fetchurl }:

let
  parsec-wrapper = pkgs.writeShellScriptBin "parsec-wrapper" ''
    ${pkgs.parsec-bin}/bin/parsecd "$@" &
    disown

    PID=$!
    ${pkgs.xdotool}/bin/xdotool search --sync --all --pid $PID --name '.*' set_window --classname "parsecd" set_window --class "parsecd"
  '';

  parsec-icon = fetchurl {
    url = "https://www.svgrepo.com/download/331528/parsec.svg";
    sha256 = "sha256-KTV90OYP4U4RKTeacmL4flc7qyz2kt2YUVCnnwsL6PY="; 
  };

  parsec-desktop = pkgs.makeDesktopItem {
    name = "parsec";
    desktopName = "Parsec";
    genericName = "Game Streaming";
    exec = "${parsec-wrapper}/bin/parsec-wrapper %u";
    icon = "${parsec-icon}";
    comment = "Simple, low-latency game streaming.";
    categories = [ "Network" "Game" "Utility" ];
  };
in
{
  wrapper = parsec-wrapper;
  desktop = parsec-desktop;
}