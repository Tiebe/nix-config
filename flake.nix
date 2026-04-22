{
  description = "Tiebe's nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
    nvf.url = "github:notashelf/nvf";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    opencode.url = "github:anomalyco/opencode";
    opencode.inputs.nixpkgs.follows = "nixpkgs";

    forgecode.url = "github:antinomyhq/forge";
    forgecode.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    agenix,
    winapps,
    stylix,
    catppuccin,
    nvf,
    nixvirt,
    nixos-hardware,
    disko,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    overlays = import ./overlays {inherit inputs;};
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    nixosConfigurations = {
      jupiter = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/jupiter];
      };

      pluto = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/pluto];
      };

      victoria = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/victoria];
      };

      mercury = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/mercury];
      };

      victoria-test-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/victoria/vm.nix];
      };
    };

    # VM image for testing erase darlings
    packages.x86_64-linux.victoria-test-vm-image = inputs.nixos-generators.nixosGenerate {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [./hosts/victoria/vm.nix];
      format = "vm";
    };

    # Installer ISO with erase-your-darlings support
    packages.x86_64-linux.installer-iso = inputs.nixos-generators.nixosGenerate {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        disko.nixosModules.disko
        ./hosts/installer
        ./hosts/installer/disko.nix
        ./hosts/installer/install-script.nix
        ./hosts/installer/persist-setup.nix
        {
          tiebe.installer.enable = true;
        }
      ];
      format = "iso";
    };

    # Checks for CI validation
    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Verify all NixOS configurations evaluate
      jupiter = self.nixosConfigurations.jupiter.config.system.build.toplevel;
      pluto = self.nixosConfigurations.pluto.config.system.build.toplevel;
      victoria = self.nixosConfigurations.victoria.config.system.build.toplevel;
      mercury = self.nixosConfigurations.mercury.config.system.build.toplevel;
      victoria-test-vm = self.nixosConfigurations.victoria-test-vm.config.system.build.toplevel;
    });
  };
}
