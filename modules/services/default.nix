{inputs, ...}: {
  imports = [
    ./docker.nix
    ./printing.nix
    ./sshserver.nix
    ./sunshine.nix
    ./vr.nix
    ./winapps.nix
  ];
}
