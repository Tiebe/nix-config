{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.terminal.utils.neovim;
in {
  options = {
    tiebe.terminal.utils.neovim = {
      enable = mkEnableOption "neovim";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {inputs, ...}: {
      imports = [inputs.nvf.homeManagerModules.default];

      programs.nvf = {
        enable = true;

        settings.vim = {
          vimAlias = true;
          viAlias = true;
          withNodeJs = true;
          # useSystemClipboard = true; // TODO: DEPRECATED

          options = {
            tabstop = 2;
            shiftwidth = 2;
            wrap = false;
          };

          keymaps = [
            {
              key = "jk";
              mode = ["i"];
              action = "<ESC>";
              desc = "Exit insert mode";
            }
            {
              key = "<leader>nh";
              mode = ["n"];
              action = ":nohl<CR>";
              desc = "Clear search highlights";
            }
            {
              key = "<leader>ff";
              mode = ["n"];
              action = "<cmd>Telescope find_files<cr>";
              desc = "Search files by name";
            }
            {
              key = "<leader>lg";
              mode = ["n"];
              action = "<cmd>Telescope live_grep<cr>";
              desc = "Search files by contents";
            }
            {
              key = "<leader>fe";
              mode = ["n"];
              action = "<cmd>Neotree toggle<cr>";
              desc = "File browser toggle";
            }
            {
              key = "o";
              mode = ["n"];
              action = "<cmd>Neotree focus<cr>";
              desc = "Focus Neotree";
            }
            {
              key = "<C-h>";
              mode = ["i"];
              action = "<Left>";
              desc = "Move left in insert mode";
            }
            {
              key = "<C-j>";
              mode = ["i"];
              action = "<Down>";
              desc = "Move down in insert mode";
            }
            {
              key = "<C-k>";
              mode = ["i"];
              action = "<Up>";
              desc = "Move up in insert mode";
            }
            {
              key = "<C-l>";
              mode = ["i"];
              action = "<Right>";
              desc = "Move right in insert mode";
            }
          ];

          telescope.enable = true;

          spellcheck = {
            enable = true;
          };

          lsp = {
            enable = true;
            formatOnSave = true;
            lspkind.enable = false;
            lightbulb.enable = true;
            lspsaga.enable = false;
            trouble.enable = true;
            lspSignature.enable = true;
            otter-nvim.enable = false;
            nvim-docs-view.enable = false;
          };

          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            nix.enable = true;
            clang.enable = true;
            zig.enable = true;
            python.enable = true;
            markdown.enable = true;
            ts.enable = true;
            html.enable = true;
          };

          visuals = {
            nvim-web-devicons.enable = true;
            nvim-cursorline.enable = true;
            cinnamon-nvim.enable = true;
            fidget-nvim.enable = true;

            highlight-undo.enable = true;
            indent-blankline.enable = true;
          };

          statusline = {
            lualine = {
              enable = true;
            };
          };

          autopairs.nvim-autopairs.enable = true;

          autocomplete.nvim-cmp.enable = true;
          snippets.luasnip = {
            enable = true;
            loaders = ''
              require("luasnip.loaders.from_vscode").lazy_load()
              require("luasnip.loaders.from_vscode").load({ paths = { ".vscode" } })
            '';
          };

          tabline = {
            nvimBufferline.enable = true;
          };

          treesitter.context.enable = true;

          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;
          };

          git = {
            enable = true;
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false; # throws an annoying debug message
          };

          projects.project-nvim.enable = true;
          dashboard.dashboard-nvim.enable = true;

          filetree.neo-tree.enable = true;

          notify = {
            nvim-notify.enable = true;
          };

          utility = {
            ccc.enable = false;
            vim-wakatime.enable = false;
            icon-picker.enable = true;
            surround.enable = true;
            diffview-nvim.enable = true;
            motion = {
              hop.enable = true;
              leap.enable = true;
              precognition.enable = false;
            };

            images = {
              image-nvim.enable = false;
            };
          };

          ui = {
            borders.enable = true;
            noice.enable = true;
            colorizer.enable = true;
            illuminate.enable = true;
            breadcrumbs = {
              enable = false;
              navbuddy.enable = false;
            };
            smartcolumn = {
              enable = false;
            };
            fastaction.enable = true;
          };

          session = {
            nvim-session-manager.enable = false;
          };

          comments = {
            comment-nvim.enable = true;
          };

          globals = {
            mapleader = ",";
          };
        };
      };
    };
  };
}
