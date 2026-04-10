{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.terminal.utils.helix;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.terminal.utils.helix = {
      enable = mkEnableOption "helix editor";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Language servers
      nil # Nix
      pyright # Python
      typescript-language-server # TypeScript/JavaScript
      rust-analyzer # Rust
      gopls # Go
      clang-tools # C/C++ (clangd)
      bash-language-server # Bash
      taplo # TOML
      yaml-language-server # YAML
      vscode-langservers-extracted # JSON
      marksman # Markdown
    ];

    home-manager.users.tiebe = {
      programs.helix = {
        enable = true;
        defaultEditor = true;

        settings = {
          editor = {
            auto-save = {
              focus-lost = true;
              after-delay.enable = false;
            };
            auto-format = true;
            file-picker.hidden = false;
            indent-guides.render = true;
            line-number = "absolute";
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            statusline = {
              left = [
                "mode"
                "spinner"
                "file-name"
                "file-modification-indicator"
              ];
              right = [
                "diagnostics"
                "selections"
                "register"
                "position"
                "file-encoding"
                "file-line-ending"
                "file-type"
              ];
            };
            lsp.display-messages = true;
          };
        };

        languages = {
          language-server = {
            nil = {
              command = "nil";
            };
            pyright = {
              command = "pyright-langserver";
              args = ["--stdio"];
            };
            typescript-language-server = {
              command = "typescript-language-server";
              args = ["--stdio"];
            };
            rust-analyzer = {
              command = "rust-analyzer";
            };
            gopls = {
              command = "gopls";
            };
            clangd = {
              command = "clangd";
            };
            bash-language-server = {
              command = "bash-language-server";
              args = ["start"];
            };
            taplo = {
              command = "taplo";
              args = ["lsp" "stdio"];
            };
            yaml-language-server = {
              command = "yaml-language-server";
              args = ["--stdio"];
            };
            vscode-json-language-server = {
              command = "vscode-json-language-server";
              args = ["--stdio"];
            };
            marksman = {
              command = "marksman";
              args = ["server"];
            };
          };

          language = [
            {
              name = "nix";
              auto-format = true;
              language-servers = ["nil"];
            }
            {
              name = "python";
              auto-format = true;
              language-servers = ["pyright"];
            }
            {
              name = "typescript";
              auto-format = true;
              language-servers = ["typescript-language-server"];
            }
            {
              name = "javascript";
              auto-format = true;
              language-servers = ["typescript-language-server"];
            }
            {
              name = "tsx";
              auto-format = true;
              language-servers = ["typescript-language-server"];
            }
            {
              name = "jsx";
              auto-format = true;
              language-servers = ["typescript-language-server"];
            }
            {
              name = "rust";
              auto-format = true;
              language-servers = ["rust-analyzer"];
            }
            {
              name = "go";
              auto-format = true;
              language-servers = ["gopls"];
            }
            {
              name = "c";
              auto-format = true;
              language-servers = ["clangd"];
            }
            {
              name = "cpp";
              auto-format = true;
              language-servers = ["clangd"];
            }
            {
              name = "bash";
              auto-format = true;
              language-servers = ["bash-language-server"];
            }
            {
              name = "toml";
              auto-format = true;
              language-servers = ["taplo"];
            }
            {
              name = "yaml";
              auto-format = true;
              language-servers = ["yaml-language-server"];
            }
            {
              name = "json";
              auto-format = true;
              language-servers = ["vscode-json-language-server"];
            }
            {
              name = "markdown";
              auto-format = true;
              language-servers = ["marksman"];
            }
          ];
        };
      };
    };
  };
}
