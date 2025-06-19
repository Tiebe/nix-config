{inputs, ...}: {
  imports = [
    ./zsh.nix
    ./utils/basic.nix
    ./utils/advanced.nix
    ./utils/fastfetch.nix
    ./utils/neovim.nix
    ./evict.nix
  ];
}
