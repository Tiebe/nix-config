# Erase Your Darlings Refactoring Plan

## Overview

This document outlines a comprehensive refactoring to rename `erase-your-darlings` to `darlings` and distribute persistence configuration across all modules. Each module will have its own `darlings.nix` file that activates when both the module and darlings are enabled.

## Architecture Principles

### 1. The Darlings Contract Pattern

Every module that owns options MUST follow this pattern:

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
  darlings = config.tiebe.system.boot.darlings;
in {
  options = {
    tiebe.<category>.<name> = {
      enable = mkEnableOption "<description>";
    };
  };

  config = mkIf cfg.enable {
    # Main module configuration
  };
  
  imports = [
    ./darlings.nix
  ];
}
```

```nix
# modules/<category>/<name>/darlings.nix
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.<category>.<name>;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Persistence configuration specific to this module
  };
}
```

### 2. Critical Rules

1. **NO conditional imports**: Never use `imports = mkIf condition [ ./file.nix ]` - this causes infinite recursion
2. **Static imports only**: All imports must be static; use `mkIf` inside `config` for conditional logic
3. **Two-condition gating**: Every `darlings.nix` MUST check BOTH `darlings.enable && cfg.enable`
4. **Preserve option names**: Do NOT rename existing module options; only rename the boot option
5. **Exclusions**: Package helpers without enable options (e.g., `ayechat.nix`) should not be converted

### 3. Folder Structure Convention

**Before (flat file):**
```
modules/services/docker.nix
```

**After (folder with companion):**
```
modules/services/docker/
├── default.nix    # Main module logic + imports ./darlings.nix
└── darlings.nix   # Persistence config
```

**Before (folder without darlings):**
```
modules/services/gpg/
└── default.nix
```

**After (folder with darlings):**
```
modules/services/gpg/
├── default.nix    # Add: imports = [ ./darlings.nix ];
└── darlings.nix   # New file
```

## Dependency Graph

```
T0: Baseline Validation
│
├─> T1: Rename Boot Module (darlings)
│   │
│   ├─> T2: System Global Darlings
│   │
│   ├─> T3: Services Batch (parallel with T4, T5)
│   │   ├─> T3A: Flat files -> folders
│   │   └─> T3B: Existing folders + darlings.nix
│   │
│   ├─> T4: Desktop Apps Batch (parallel)
│   │   ├─> T4A: Flat files -> folders
│   │   ├─> T4B: Existing folders + darlings.nix
│   │   └─> T4C: Plasma/Hyprland/Theme normalization
│   │
│   └─> T5: System/Base/Terminal Batch (parallel)
│       ├─> T5A: System modules
│       ├─> T5B: Base modules
│       └─> T5C: Terminal modules
│
└─> T6: Parent Import Rewires (depends on T2-T5)
    │
    └─> T7: Final Validation
```

## Task Definitions

---

### T0: Baseline Validation Harness

**Goal**: Establish pre-refactor safety baseline and build validation harness

**Deliverables**:
1. Baseline evaluation for all hosts (jupiter, victoria, pluto, mercury)
2. Add flake checks to flake.nix for continuous validation
3. Document current working state

**Files to Modify**:
- `/home/tiebe/nix-config/flake.nix` - Add checks

**Files to Read (not modify)**:
- `/home/tiebe/nix-config/hosts/jupiter/modules.nix`
- `/home/tiebe/nix-config/hosts/victoria/modules.nix`
- `/home/tiebe/nix-config/hosts/pluto/modules.nix`
- `/home/tiebe/nix-config/hosts/mercury/modules.nix`

**Success Criteria**:
```bash
nix flake check --no-build  # Evaluates without errors
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.victoria.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.pluto.config.system.build.toplevel --dry-run
```

**Delegation Prompt**:
```
TASK: Create baseline validation harness for erase-your-darlings refactor

CONTEXT: We're about to rename tiebe.system.boot.erase-your-darlings to 
tiebe.system.boot.darlings and reorganize 50+ modules. We need safety harnesses.

MUST DO:
1. Read flake.nix and add checks output that builds all nixosConfigurations
2. Verify current state: all hosts (jupiter, victoria, pluto, mercury) evaluate
3. Document baseline in .sisyphus/plans/baseline-status.md

MUST NOT DO:
- Do not modify any module files yet
- Do not change any options or imports

EXPECTED OUTCOME:
- flake.nix has working checks output
- Document confirming all 4 hosts evaluate successfully
- No functional changes to configurations
```

---

### T1: Rename Boot Module

**Goal**: Rename `erase-your-darlings` to `darlings` in boot module

**Files to Create**:
- `/home/tiebe/nix-config/modules/system/boot/darlings/default.nix`

**Files to Delete**:
- `/home/tiebe/nix-config/modules/system/boot/erase-your-darlings/` (entire folder)

**Files to Modify**:
- `/home/tiebe/nix-config/modules/system/default.nix` - Change import path
- `/home/tiebe/nix-config/hosts/jupiter/modules.nix` - Change option name

**Content for new darlings/default.nix**:
```nix
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.darlings;
in {
  options = {
    tiebe.system.boot.darlings = {
      enable = mkEnableOption "darlings (erase your darlings) ephemeral root setup";
    };
  };

  config = mkIf cfg.enable {
    # Core boot persistence config
    # (machine-id, nixos symlink, sudo lecture, mutableUsers)
    # SSH host keys MOVED to ssh-server/darlings.nix
    # Docker tmpfiles MOVED to docker/darlings.nix
    # fprintd/backlight MOVED to system/darlings.nix
  };
}
```

**Success Criteria**:
- `nix flake check` passes
- `jupiter` host evaluates with new option name
- Old `erase-your-darlings.enable` path no longer referenced

---

### T2: System Global Darlings

**Goal**: Create global system persistence module for cross-cutting concerns

**Files to Create**:
- `/home/tiebe/nix-config/modules/system/darlings.nix`

**Files to Modify**:
- `/home/tiebe/nix-config/modules/system/default.nix` - Add import

**Content for modules/system/darlings.nix**:
```nix
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf darlings.enable {
    # Global persistence not tied to specific modules
    # - systemd-backlight@ service dependency on persist.mount
    # - fprintd StateDirectory override
    # - Any other global state preservation
  };
}
```

**Distribution of existing erase-your-darlings config**:

| Current Location | Target Location | Notes |
|-----------------|-----------------|-------|
| `services.openssh.hostKeys` | `modules/services/ssh-server/darlings.nix` | Only if ssh-server enabled |
| `environment.etc.nixos.source` | Keep in `boot/darlings/default.nix` | System-wide |
| `environment.etc.machine-id.source` | Keep in `boot/darlings/default.nix` | System-wide |
| `security.sudo.extraConfig` | Keep in `boot/darlings/default.nix` | System-wide |
| `systemd.tmpfiles.rules` (docker) | `modules/services/docker/darlings.nix` | Module-specific |
| `systemd.tmpfiles.rules` (fprint) | `modules/system/darlings.nix` | Could also go to printing |
| `systemd.tmpfiles.rules` (backlight) | `modules/system/darlings.nix` | Global |
| `systemd.services.fprintd` | `modules/system/darlings.nix` | Or printing/darlings.nix |
| `systemd.services.systemd-backlight@` | `modules/system/darlings.nix` | Global |
| `users.mutableUsers` | Keep in `boot/darlings/default.nix` | System-wide |

---

### T3: Services Modules Batch

#### T3A: Flat Files to Folders

Convert these flat files to folder structure with darlings.nix:

1. **sshserver.nix** → `ssh-server/`
   - Option: `tiebe.services.ssh-server`
   - Parent: `modules/services/default.nix`
   - Darlings content: SSH host keys persistence

2. **docker.nix** → `docker/`
   - Option: `tiebe.services.docker`
   - Darlings content: `/var/lib/docker` tmpfiles rule

3. **podman.nix** → `podman/`
   - Option: `tiebe.services.podman`
   - Darlings: Podman state persistence (if any)

4. **sunshine.nix** → `sunshine/`
   - Option: `tiebe.services.sunshine`

5. **devenv.nix** → `devenv/`
   - Option: `tiebe.services.devenv`

6. **cachix.nix** → `cachix/`
   - Option: `tiebe.services.cachix`

7. **printing.nix** → `printing/`
   - Option: `tiebe.services.printing`
   - Darlings: Consider if fprintd belongs here

8. **lorri.nix** → `lorri/`
   - Option: `tiebe.services.lorri`

9. **nextcloud.nix** → `nextcloud/`
   - Option: `tiebe.services.nextcloud`

10. **winapps.nix** → `winapps/`
    - Option: `tiebe.services.winapps`

#### T3B: Existing Folders + Darlings

Add darlings.nix to these existing folders:

1. `modules/services/gpg/` - GPG key persistence
2. `modules/services/openvpn/` - VPN config persistence
3. `modules/services/ratbagd/` - Mouse config
4. `modules/services/variety/` - Wallpaper settings
5. `modules/services/vr/` - VR runtime state
6. `modules/services/windows/` - VM disk paths (already uses /persist)
7. `modules/services/bitfocus-companion/` - Companion config
8. `modules/services/zerogravity/` - Project-specific state

**Parent Updates**: `modules/services/default.nix`

---

### T4: Desktop Apps Batch

#### T4A: Flat Files to Folders

Convert to folder + darlings.nix:

1. **bitwarden.nix** → `bitwarden/`
2. **firefox.nix** → `firefox/`
   - Profile persistence in ~/.mozilla
3. **intellij.nix** → `intellij/`
4. **legcord.nix** → `legcord/`
5. **lmstudio.nix** → `lmstudio/`
6. **localsend.nix** → `localsend/`
7. **media.nix** → `media/`
8. **minecraft.nix** → `minecraft/`
9. **obsidian.nix** → `obsidian/`
   - Vault locations in persist
10. **office.nix** → `office/`
11. **opencode.nix** → `opencode/`
12. **thunderbird.nix** → `thunderbird/`
    - Mail profile persistence
13. **vencord.nix** → `vencord/`
14. **vscode.nix** → `vscode/`
    - Extensions and settings

#### T4B: Existing Folders + Darlings

Add darlings.nix to:
1. `modules/desktop/apps/steam/` - Steam library paths
2. `modules/desktop/apps/discord/` - Discord config
3. `modules/desktop/apps/parsec/` - Parsec settings
4. `modules/desktop/apps/httptoolkit/` - HTTPToolkit state
5. `modules/desktop/apps/wezterm/` - Wezterm config

#### T4C: Plasma/Hyprland/Theme Normalization

**Plasma**:
- `modules/desktop/plasma/config.nix` → `modules/desktop/plasma/config/`
- Add `modules/desktop/plasma/darlings.nix`
- Update import in `modules/desktop/plasma/default.nix`

**Hyprland**:
- Fold `hyprland.nix` into `default.nix` root
- Convert to folders:
  - `hypridle.nix` → `hypridle/`
  - `hyprlock.nix` → `hyprlock/`
- Add darlings.nix at:
  - `modules/desktop/hyprland/darlings.nix`
  - `modules/desktop/hyprland/hypridle/darlings.nix`
  - `modules/desktop/hyprland/hyprlock/darlings.nix`
- Keep `config/` and `programs/` as aggregators (no enable option = no darlings needed)

**Theme**:
- Add `modules/desktop/theme/darlings.nix`
- Convert `catppuccin.nix` → `catppuccin/` folder
- Update `modules/default.nix` to import `./desktop/theme` instead of direct file

---

### T5: System/Base/Terminal Batch

#### T5A: System Modules

Flat files to folders:
1. **sound.nix** → `modules/system/sound/`
2. **ddc.nix** → `modules/system/ddc/`
3. **boot/plymouth.nix** → `boot/plymouth/`
4. **boot/systemdboot.nix** → `boot/systemdboot/` (option name stays `systemd-boot`)
5. **networking/bluetooth.nix** → `networking/bluetooth/`
6. **networking/network.nix** → `networking/network/`
7. **networking/tailscale.nix** → `networking/tailscale/`

Folders to add darlings.nix:
1. `modules/system/networking/wifi/` - WiFi profiles
2. `modules/system/users/tiebe/` - User home persistence rules
3. `modules/system/users/robbin/` - User home persistence rules

Nested conversion:
1. `modules/system/users/tiebe/email.nix` → `modules/system/users/tiebe/email/`

#### T5B: Base Modules

Flat files to folders:
1. **age.nix** → `modules/base/age/`
2. **locale.nix** → `modules/base/locale/`
3. **nix.nix** → `modules/base/nix/`

#### T5C: Terminal Modules

Flat files to folders:
1. **zsh.nix** → `modules/terminal/zsh/`
2. **utils/neovim.nix** → `utils/neovim/`
3. **utils/fastfetch.nix** → `utils/fastfetch/`
4. **utils/basic.nix** → `utils/basic/`
5. **utils/advanced.nix** → `utils/advanced/`

Exclusion:
- `modules/terminal/utils/ayechat.nix` - Package helper, NOT an enable module

---

### T6: Parent Import Rewires

**Goal**: Update all parent default.nix files to import from new folder paths

**Files to Modify**:

1. `/home/tiebe/nix-config/modules/default.nix`
   - Change: `./desktop/theme/catppuccin.nix` → `./desktop/theme`

2. `/home/tiebe/nix-config/modules/system/default.nix`
   - Change: `./boot/erase-your-darlings` → `./boot/darlings`
   - Add: `./darlings.nix`
   - Change all flat imports to folder imports

3. `/home/tiebe/nix-config/modules/services/default.nix`
   - Change: `./docker.nix` → `./docker`
   - Change: `./sshserver.nix` → `./ssh-server`
   - (etc for all converted modules)

4. `/home/tiebe/nix-config/modules/desktop/apps/default.nix`
   - Update all imports to folder paths

5. `/home/tiebe/nix-config/modules/base/default.nix`
   - Update all imports to folder paths

6. `/home/tiebe/nix-config/modules/terminal/default.nix`
   - Update all imports to folder paths

7. `/home/tiebe/nix-config/modules/desktop/plasma/default.nix`
   - Change: `./config.nix` → `./config`
   - Add darlings import or inline in default.nix

8. `/home/tiebe/nix-config/modules/desktop/hyprland/default.nix`
   - Reorganize imports after folding hyprland.nix

9. `/home/tiebe/nix-config/modules/desktop/theme/default.nix`
   - Add darlings.nix import
   - Add catppuccin folder import

---

### T7: Final Validation

**Goal**: Comprehensive verification of entire refactor

**Validation Checklist**:

1. **Evaluation Tests**:
   ```bash
   nix flake check
   for host in jupiter victoria pluto mercury; do
     nix build .#nixosConfigurations.$host.config.system.build.toplevel --dry-run
   done
   ```

2. **Grep Assertions**:
   ```bash
   # Must be ZERO occurrences
   grep -r "erase-your-darlings" modules/ hosts/ --include="*.nix"
   grep -r "tiebe.system.boot.erase-your-darlings" modules/ hosts/ --include="*.nix"
   
   # Must find imports (sanity check)
   grep -r "./darlings.nix" modules/ --include="*.nix" | wc -l  # Should be ~40+
   ```

3. **Structure Verification**:
   ```bash
   # Every option-owning module should have darlings.nix
   find modules -name "default.nix" -exec dirname {} \; | while read dir; do
     if [ -f "$dir/default.nix" ] && grep -q "mkEnableOption" "$dir/default.nix"; then
       if [ ! -f "$dir/darlings.nix" ]; then
         echo "MISSING: $dir/darlings.nix"
       fi
     fi
   done
   ```

4. **Import Consistency**:
   - No `../file.nix` imports remaining for converted modules
   - All parent default.nix files use folder imports only

5. **Dry-Activate (on jupiter)**:
   ```bash
   sudo nixos-rebuild dry-activate --flake .#jupiter
   ```

---

## Subagent Delegation Strategy

### Recommended Subagent Types

- **T0, T7**: `deep` agent (validation-heavy, needs careful testing)
- **T1, T2**: `quick` or `unspecified-high` (focused, well-defined scope)
- **T3, T4, T5**: `unspecified-high` agents in parallel (implementation batches)
- **T6**: `quick` agent (import updates are mechanical)

### Parallel Execution Groups

**Group 1 (Can run in parallel after T1)**:
- T2: System global darlings
- T3: Services batch
- T4: Desktop apps batch
- T5: System/base/terminal batch

**Group 2 (Depends on Group 1)**:
- T6: Parent import rewires

**Group 3 (Depends on T6)**:
- T7: Final validation

### Atomic Commits

Each subagent task should produce atomic commits:

1. `refactor(darlings): add baseline validation harness`
2. `refactor(darlings): rename erase-your-darlings to darlings`
3. `refactor(darlings): add system global darlings module`
4. `refactor(darlings): convert services modules to folder+darlings pattern`
5. `refactor(darlings): convert desktop app modules to folder+darlings pattern`
6. `refactor(darlings): convert system/base/terminal modules`
7. `refactor(darlings): update parent imports`
8. `refactor(darlings): final validation and cleanup`

---

## Risk Mitigation

### Rollback Strategy

1. Keep git history clean with atomic commits
2. Each commit should be individually reversible
3. If any validation fails, revert to last known good commit

### Common Pitfalls

1. **Infinite Recursion**: Caused by conditional imports. Use static imports only.
2. **Missing Darlings Check**: Forgetting to check `cfg.enable` in darlings.nix
3. **Parent Import Stale**: Updating module but forgetting parent default.nix
4. **Option Rename**: Accidentally renaming module options (should only rename boot option)

### Validation Gates

Each task must pass before proceeding:
- ✅ `nix flake check` evaluates
- ✅ All hosts build (or dry-run)
- ✅ No `erase-your-darlings` references remain in modified scope
- ✅ All new modules have darlings.nix with proper pattern

---

## Appendix: Module Inventory

### Services - Flat Files to Convert

| File | Option | Darlings Content |
|------|--------|------------------|
| sshserver.nix | tiebe.services.ssh-server | SSH host keys |
| docker.nix | tiebe.services.docker | /var/lib/docker |
| podman.nix | tiebe.services.podman | Podman state |
| sunshine.nix | tiebe.services.sunshine | Sunshine config |
| devenv.nix | tiebe.services.devenv | Devenv caches |
| cachix.nix | tiebe.services.cachix | Cachix tokens |
| printing.nix | tiebe.services.printing | fprintd state? |
| lorri.nix | tiebe.services.lorri | Lorri gc roots |
| nextcloud.nix | tiebe.services.nextcloud | Nextcloud data |
| winapps.nix | tiebe.services.winapps | WinApps config |

### Desktop Apps - Flat Files to Convert

| File | Option |
|------|--------|
| bitwarden.nix | tiebe.desktop.apps.bitwarden |
| firefox.nix | tiebe.desktop.apps.firefox |
| intellij.nix | tiebe.desktop.apps.intellij |
| legcord.nix | tiebe.desktop.apps.legcord |
| lmstudio.nix | tiebe.desktop.apps.lmstudio |
| localsend.nix | tiebe.desktop.apps.localsend |
| media.nix | tiebe.desktop.apps.media |
| minecraft.nix | tiebe.desktop.apps.minecraft |
| obsidian.nix | tiebe.desktop.apps.obsidian |
| office.nix | tiebe.desktop.apps.office |
| opencode.nix | tiebe.desktop.apps.opencode |
| thunderbird.nix | tiebe.desktop.apps.thunderbird |
| vencord.nix | tiebe.desktop.apps.vencord |
| vscode.nix | tiebe.desktop.apps.vscode |

### System - Flat Files to Convert

| File | Option |
|------|--------|
| sound.nix | tiebe.system.sound |
| ddc.nix | tiebe.system.ddc |
| boot/plymouth.nix | tiebe.system.boot.plymouth |
| boot/systemdboot.nix | tiebe.system.boot.systemd-boot |
| networking/bluetooth.nix | tiebe.system.networking.bluetooth |
| networking/network.nix | tiebe.system.networking.network |
| networking/tailscale.nix | tiebe.system.networking.tailscale |

### Base - Flat Files to Convert

| File | Option |
|------|--------|
| age.nix | tiebe.base.age |
| locale.nix | tiebe.base.locale |
| nix.nix | tiebe.base.nix |

### Terminal - Flat Files to Convert

| File | Option |
|------|--------|
| zsh.nix | tiebe.terminal.zsh |
| utils/neovim.nix | tiebe.terminal.utils.neovim |
| utils/fastfetch.nix | tiebe.terminal.utils.fastfetch |
| utils/basic.nix | tiebe.terminal.utils.basic |
| utils/advanced.nix | tiebe.terminal.utils.advanced |

### Nested Conversions

| File | New Location |
|------|-------------|
| system/users/tiebe/email.nix | system/users/tiebe/email/ |
| desktop/plasma/config.nix | desktop/plasma/config/ |
| desktop/theme/catppuccin.nix | desktop/theme/catppuccin/ |
| desktop/hyprland/hyprland.nix | INTO desktop/hyprland/default.nix |
| desktop/hyprland/hypridle.nix | desktop/hyprland/hypridle/ |
| desktop/hyprland/hyprlock.nix | desktop/hyprland/hyprlock/ |
