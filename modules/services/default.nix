{inputs, ...}: {
  imports = [
    ./docker.nix
    ./printing.nix
    ./sshserver.nix
    ./sunshine.nix
    ./vr.nix
    ./winapps.nix
    ./gpg
    ./lorri.nix
    ./podman.nix
    ./cachix.nix
    ./openvpn
    ./windows
    ./nextcloud.nix
    ./devenv.nix
    ./variety
    ./bitfocus-companion
  ];
}
