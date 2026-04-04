# Agent Guidelines for nix-config

## CRITICAL RULE

**Always commit after every change.** No exceptions. Every file edit, addition, or
deletion must be followed by a `git add` and `git commit` before moving on.
Use descriptive commit messages (see Git section below).

---

## Project Overview

NixOS flake-based system configuration using flakes. Pure Nix — no other languages. Manages multiple hosts with a modular architecture.

- **Hosts**: jupiter, pluto, victoria, mercury (all x86_64-linux)
- **Modules**: `modules/{base,desktop,system,services,terminal}/`
- **Host configs**: `hosts/<hostname>/`
- **Overlays**: `overlays/`
- **Secrets**: `secrets/` (agenix/ragenix — do NOT modify without explicit instruction)
- **CI**: `.forgejo/workflows/`

---

## Build, Format & Validate

```bash
# Format all Nix files (alejandra)
nix fmt

# Validate the flake (evaluates all outputs, catches syntax/eval errors)
nix flake check

# Build a specific host configuration (dry-run)
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run
# Replace <host> with: jupiter, pluto, victoria, mercury

# Build and switch on the current host
sudo nixos-rebuild switch --flake .#<host>

# Apply config on the current host
sudo nixos-rebuild switch --flake .

# Update flake inputs
nix flake update

# Check evaluation for all hosts (defined in flake.nix checks)
nix flake check --no-build
```

**There are no tests.** Validation is `nix fmt` + `nix flake check`.
Always run both before committing.

---

## Git Workflow

### Commit Rules

1. **Commit after every change** — atomic commits, one logical change each
2. Run `nix fmt` before committing
3. Run `nix flake check` before committing
4. Never leave uncommitted changes

### Commit Message Style

Use conventional commits when the scope is clear:

```
feat(desktop): add Firefox PWA support
fix(services): correct Docker network config
chore(flake): bump inputs
refactor(base): simplify locale module
```

For simple changes, a short descriptive message is acceptable.

---

## Code Style Guidelines

### Formatting

- **Formatter**: `alejandra` (configured in `flake.nix`)
- Always run `nix fmt` before committing
- **Indentation**: 2 spaces, no tabs
- **No trailing commas** in attribute sets or lists
- **Lists** (2+ items): one item per line
- **Lists** (1 item): inline is fine
- **Attribute sets**: one key-value pair per line; inline only for single short entries
- **`with pkgs;`**: used on the same line as `[` for package lists
- **Multiline strings**: use `'' ... ''` for embedded shell scripts
- **String interpolation**: `${pkgs.package}/bin/executable`
- **Comments**: `#` for inline/above; `/* */` for section headers
- Always run `nix fmt` (alejandra) — it handles most formatting automatically

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

Key rules:
- Function arguments: one per line, full list
- `}: let` on the same line as the closing brace
- Always `inherit (lib) ...;` — never `with lib;`
- Always gate config with `mkIf cfg.enable`
- Options live under `tiebe.<category>.<module>`

### Complex Options

For options beyond a simple enable toggle:

```nix
options.tiebe.<category>.<module> = {
  enable = mkEnableOption "<description>";
  someOption = lib.mkOption {
    type = types.str;
    description = "What this option does";
  };
};
```

### Aggregator Files (default.nix)

Aggregator files that just import submodules use a minimal signature:

```nix
{inputs, ...}: {
  imports = [
    (import ./submodule.nix {inherit inputs;})
  ];
}
```

### lib Usage

- Use `lib.mkMerge`, `lib.mkBefore`, `lib.mkForce`, `lib.mkDefault` with the `lib.` prefix
- Use `inherit (lib) ...;` in let-bindings for frequently used functions
- Do NOT use `with lib;` at the top level
- Do NOT define custom lib functions — use nixpkgs lib exclusively

### home-manager Integration

home-manager config goes inside the same `mkIf` block:

```nix
config = mkIf cfg.enable {
  # NixOS-level config here

  home-manager.users.tiebe = {
    # home-manager config here
  };
};
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

---

## Secrets Management

Managed by **agenix** (ragenix). Encrypted with yubikey + host SSH keys.

- Secrets stored in `secrets/` directory with `.age` extension
- Secret declarations: `secrets/secrets.nix`
- Public keys defined in `secrets/secrets.nix`
- YubiKey-based encryption with age-plugin-yubikey
- **Do NOT edit secrets** unless explicitly asked
- **Do NOT commit unencrypted secret material**
- Never commit plaintext secrets

---

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

**⚠️ CRITICAL: DO NOT use systemd tmpfiles for /users/ directory**

Tmpfiles rules create files/directories as root:root before the user exists, causing permission errors. For evict-darlings persistence:
- Use `home-manager` to create directories on first login
- Use systemd user services with proper `User=` directives
- NEVER use `systemd.tmpfiles.rules` for paths under `/users/`

---

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

---

## CI/CD

- **Platform**: Forgejo (`.forgejo/workflows/update.yml`)
- **Schedule**: Weekly flake.lock updates
- **Auto-merge**: Enabled for lock file updates

---

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

### Home Manager Persistence with mkOutOfStoreSymlink

When using `home.file` or `xdg.dataFile` with `mkOutOfStoreSymlink` to persist directories to `/persist`, **you MUST also create the target directories in `/persist`** before the symlinks are set up.

**Problem**: `mkOutOfStoreSymlink` only creates the symlink, not the target directory. If the target doesn't exist, the symlink will be broken.

**Solution**: Use `home.activation` to create directories before the `writeBoundary`:

```nix
# In darlings.nix
{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.<category>.<name>;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = { config, ... }: {
      home.file."<path>".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/<target-path>";

      # CRITICAL: Create /persist directories BEFORE symlinks are created
      home.activation.create<Name>PersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          "/persist/<target-path>"
      '';
    };
  };
}
```

**Key points**:
- Use `lib.hm.dag.entryBefore ["writeBoundary"]` to ensure directories exist before home-manager creates symlinks
- Import `pkgs` in the module arguments to access `coreutils`
- Create ALL target directories that are symlinked via `mkOutOfStoreSymlink`
- Handle both evict-darlings and standard paths with conditional logic

**See examples**: `modules/desktop/apps/opencode/darlings.nix`, `modules/desktop/apps/steam/darlings.nix`

### Package Overrides
```nix
firefoxPackage = pkgs.firefox.overrideAttrs (oldAttrs: {
  buildCommand = oldAttrs.buildCommand + ''
    wrapProgram "$out/bin/firefox" \
      --set HOME "${evictCfg.configDir}"
  '';
});
```

---

## Testing Changes

**Use `victoria` host for testing** - Victoria has `opencode.enable = true` and `steam.enable = true` with both `darlings` and `evictDarlings` enabled, making it a comprehensive test case for persistence modules.

1. Format: `nix fmt`
2. Check evaluation: `nix flake check`
3. Dry-run build (use victoria for testing):
   ```bash
   nix build .#nixosConfigurations.victoria.config.system.build.toplevel --dry-run
   ```
4. Test on target host: `sudo nixos-rebuild switch --flake .#<host>`

---

## Things to Avoid

- Adding new flake inputs without explicit permission
- Modifying `flake.lock` manually (use `nix flake update`)
- Using `with lib;` at module top level
- Leaving broken configurations — always validate with `nix flake check`
- Editing files in `secrets/` or `.forgejo/workflows/` without being asked
- Creating overly complex module structures — keep it flat and simple

---

## External Resources

- Flake inputs use `nixpkgs/nixos-unstable`
- Home Manager follows nixpkgs
- Secret management: https://github.com/yaxitech/ragenix
