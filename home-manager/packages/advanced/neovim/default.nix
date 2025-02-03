{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  nvimDir = "${specialArgs.custom.root}/home-manager/packages/advanced/neovim";
in {
  config = {
    programs.neovim = {
      enable = true;
      # package = nvimPackage;
      defaultEditor = true;
      extraPackages =
        [
          # Formatters
          pkgs.nixfmt-rfc-style # Nix
          pkgs.black # Python
          pkgs.prettierd # Multi-language
          pkgs.shfmt # Shell
          pkgs.isort # Python
          pkgs.stylua # Lua

          # LSP
          pkgs.lua-language-server
          pkgs.nixd
          pkgs.nil

          # Tools
          pkgs.cmake
          pkgs.fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
          pkgs.fzf
          pkgs.gcc
          pkgs.git
          pkgs.gnumake
          pkgs.nodejs
          pkgs.sqlite
          pkgs.tree-sitter
          pkgs.luarocks
        ]
        ++ lib.lists.optional (!pkgs.stdenv.isDarwin) pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
      plugins = [
        pkgs.vimPlugins.lazy-nvim # All other plugins are managed by lazy-nvim
      ];
    };

    home.file = {
      # Raw symlink to the plugin manager lock file, so that it stays writeable
      ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";

      # ".config/nvim/init.lua".text =
      #   # lua
      #   ''
      #     package.path = package.path .. ";${config.home.homeDirectory}/.config/nvim/nix/?.lua"

      #     vim.g.gcc_bin_path = '${lib.getExe pkgs.gcc}'
      #     vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
      #       if pkgs.stdenv.isDarwin
      #       then "dylib"
      #       else "so"
      #     }'

      #     require("config")
      #   '';

      # Out of store symlink of whe whole configuration, for more agility when editing it
      ".config/nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/config/lua";
    };

    home.activation.neovim =
      lib.hm.dag.entryAfter ["linkGeneration"] # bash
      
      ''
        LOCK_FILE=$(readlink -f ~/.config/nvim/lazy-lock.json)
        echo $LOCK_FILE
        [ ! -f "$LOCK_FILE" ] && echo "No lock file found, skipping" && exit 0

        STATE_DIR=~/.local/state/nix/
        STATE_FILE=$STATE_DIR/lazy-lock-checksum

        [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
        [ ! -f $STATE_FILE ] && touch $STATE_FILE

        HASH=$(nix-hash --flat $LOCK_FILE)

        if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
          echo "Syncing neovim plugins"
          $DRY_RUN_CMD ${config.programs.neovim.finalPackage}/bin/nvim --headless "+Lazy! restore" +qa
          $DRY_RUN_CMD echo $HASH >$STATE_FILE
        else
          $VERBOSE_ECHO "Neovim plugins already synced, skipping"
        fi
      '';
  };
}
