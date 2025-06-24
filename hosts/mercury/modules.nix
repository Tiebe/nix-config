{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../../modules];

  config.tiebe = {
    base = {
      age.enable = true;
      locale.enable = true;
      nix.enable = true;
    };

    system = {
      users.tiebe.enable = true;
    };

    theme.catppuccin.enable = true;

    desktop = {
      gnome.enable = true;

      apps = {
        vscode.enable = true;
        wezterm.enable = true;
      };
    };

    terminal = {
      zsh.enable = true;
      utils = {
        basic.enable = true;
        advanced.enable = true;
      };
    };

    services = {
      docker.enable = true;
      gpg.enable = true;
      lorri.enable = true;
    };
  };
}
