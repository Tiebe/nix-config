# Agent Guidelines for nix-config

This is a NixOS configuration repository using flakes. It manages multiple hosts (jupiter, victoria, pluto, mercury) with a modular architecture.

## Build/Lint/Test Commands

```bash
# Format all nix files (uses alejandra)
nix fmt

# Validate flake evaluates
nix flake check

# Build a specific host configuration (dry-run)
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run

# Build and switch on the current host
sudo nixos-rebuild switch --flake .#<host>

# Update flake inputs
nix flake update

# Check evaluation for all hosts (defined in flake.nix checks)
nix flake check --no-build
```

## Code Style Guidelines

### Formatting
- **Formatter**: `alejandra` (configured in `flake.nix`)
- Always run `nix fmt` before committing
- 2-space indentation
- No tabs

### Module Structure

Every module that owns options follows this pattern:

```nix
# modules/<category>/<name>/default.nix
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.<category>.<name>;
in {
  imports = [
    ./darlings.nix  # Always import darlings companion
  ];

  options = {
    tiebe.<category>.<name> = {
      enable = mkEnableOption "<description>";
    };
  };

  config = mkIf cfg.enable {
    # Main module configuration
  };
}
```

### Darlings Pattern (Persistence)

**CRITICAL RULES**:
1. **NO conditional imports**: Never use `imports = mkIf condition [ ./file.nix ]` - causes infinite recursion
2. **Static imports only**: All imports must be static; use `mkIf` inside `config` for conditional logic
3. **Two-condition gating**: Every `darlings.nix` MUST check BOTH `darlings.enable && cfg.enable`

```nix
# modules/<category>/<name>/darlings.nix
{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.<category>.<name>;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Persistence configuration specific to this module
  };
}
```

### Naming Conventions

- **Options prefix**: `tiebe.<category>.<name>`
  - Categories: `base`, `system`, `desktop`, `services`, `terminal`
  - Examples: `tiebe.system.boot.darlings`, `tiebe.services.docker`
- **File naming**: kebab-case (e.g., `ssh-server.nix` → `ssh-server/`)
- **Folders**: Module folders are kebab-case, containing `default.nix` and `darlings.nix`

### Imports

- Use static imports only
- Parent `default.nix` files import child folders: `./docker` not `./docker.nix`
- Import order doesn't matter but keep alphabetical when possible

### Secrets Management

- Uses `agenix` (ragenix) for encrypted secrets
- Secrets stored in `secrets/` directory with `.age` extension
- Public keys defined in `secrets/secrets.nix`
- YubiKey-based encryption with age-plugin-yubikey
- Never commit plaintext secrets

## Erase Your Darlings (Ephemeral Root)

**Concept**: Root filesystem is ephemeral (tmpfs/erased on reboot). Persistence is opt-in via the darlings pattern.

**Key Module**: `modules/system/boot/darlings/`

When `tiebe.system.boot.darlings.enable = true`:
- `/etc/nixos` → symlinked to `/persist/etc/nixos`
- `/etc/machine-id` → symlinked to `/persist/etc/machine-id`
- SSH host keys moved to `/persist`
- Each module handles its own persistence in `darlings.nix`

## Evict Your Darlings (Two-Tier Home)

**Concept**: Separates config files from personal data in home directory.

**Key Module**: `modules/system/boot/evict-darlings/`

When `tiebe.system.boot.evictDarlings.enable = true`:
- Home directory becomes `/users/<username>/` (not `/home/`)
- `config/` - Application configuration files
- `home/` - User documents and personal files
- Applications may need HOME override (see firefox example)

## Module Categories

```
modules/
├── base/          # Base system (age, locale, nix)
├── desktop/       # Desktop environments and apps
│   ├── apps/      # Desktop applications
│   ├── gnome/     # GNOME DE
│   ├── hyprland/  # Hyprland WM
│   ├── plasma/    # KDE Plasma
│   └── theme/     # Theming (Catppuccin)
├── services/      # System services (docker, ssh, etc.)
├── system/        # System config (boot, networking, sound, users)
└── terminal/      # Terminal environment (zsh, utils)
```

## Host Configurations

- **jupiter**: Main desktop (AMD GPU, Plasma)
- **victoria**: Laptop (Intel/AMD hybrid)
- **pluto**: Server/minimal
- **mercury**: Additional host

Each host has:
- `default.nix` - Host-specific hardware and config
- `hardware-configuration.nix` - Generated hardware config
- `modules.nix` - Which modules are enabled for this host

## CI/CD

- **Platform**: Forgejo (`.forgejo/workflows/update.yml`)
- **Schedule**: Weekly flake.lock updates
- **Auto-merge**: Enabled for lock file updates

## Common Patterns

### Home Manager Integration
```nix
home-manager.users.tiebe = {
  # user config
};
```

### Systemd Services
```nix
systemd.services.<name> = {
  after = ["persist.mount"];  # If using darlings
  serviceConfig = {
    # config
  };
};
```

### Tmpfiles Rules (Persistence)
```nix
systemd.tmpfiles.rules = [
  "L+ /var/lib/<path> - - - - /persist/var/lib/<path>"
];
```

### Package Overrides
```nix
firefoxPackage = pkgs.firefox.overrideAttrs (oldAttrs: {
  buildCommand = oldAttrs.buildCommand + ''
    wrapProgram "$out/bin/firefox" \
      --set HOME "${evictCfg.configDir}"
  '';
});
```

## Testing Changes

1. Format: `nix fmt`
2. Check evaluation: `nix flake check`
3. Dry-run build: `nix build .#<host>.config.system.build.toplevel --dry-run`
4. Test on target host: `sudo nixos-rebuild switch --flake .#<host>`

## External Resources

- Flake inputs use `nixpkgs/nixos-unstable`
- Home Manager follows nixpkgs
- Secret management: https://github.com/yaxitech/ragenix
