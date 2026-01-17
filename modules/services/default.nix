{inputs, ...}: {
  imports = [
    ./docker
    ./fingerprint
    ./printing
    ./ssh-server
    ./sunshine
    ./vr
    ./winapps
    ./gpg
    ./lorri
    ./podman
    ./cachix
    ./openvpn
    ./windows
    ./nextcloud
    ./devenv
    ./variety
    ./bitfocus-companion
    ./ratbagd
    ./boinc.nix
  ];
}
