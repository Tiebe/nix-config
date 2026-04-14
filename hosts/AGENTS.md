# Host Configurations

## OVERVIEW

Each host has three files: `default.nix` (hardware only), `modules.nix` (all `tiebe.*` toggles), `hardware-configuration.nix` (generated). Mercury (WSL) has no hardware-configuration.nix.

## HOST MATRIX

| Host | CPU | GPU | FS | DE | Darlings | Evict | Kernel | stateVersion |
|------|-----|-----|----|----|----------|-------|--------|--------------|
| jupiter | Intel | AMD | btrfs | Plasma + Hyprland | false | false | CachyOS | 24.05 |
| victoria | AMD (Framework) | AMD | btrfs | Hyprland | **true** | **true** | CachyOS zen4 | 25.05 |
| pluto | Intel | Intel + DisplayLink | ext4 | GNOME | false | false | default | 23.11 |
| mercury | — (WSL2) | — (WSLg) | — | GNOME | false | false | WSL | 24.05 |

## SPECIAL HOSTS

- **victoria** — Designated test host. Full ephemeral root + two-tier home. Use for `nix build --dry-run` validation.
- **installer/** — Not a real machine. Generates ISO with disko partitioning via `nixos-generators`.
- **victoria-test-vm** — VM variant defined in flake.nix for testing. Uses `lib.mkForce` + `builtins.toFile` to bypass real secrets.

## JUPITER HARDWARE INVENTORY

- Steelseries Nova Arctis Pro Wireless
- Three monitors:
  - 1× 1440p 27" 155Hz
  - 1× 1440p 32" 165Hz
  - 1× 1080p 22" 60Hz
- HyperX Solocast microphone
- 8BitDo Ultimate 2 controller
- Stream Deck
- Logitech Brio webcam

## WHERE TO LOOK

| Task | File | Notes |
|------|------|-------|
| Enable/disable a module | `<host>/modules.nix` | All `config.tiebe.*` toggles live here |
| Change kernel/GPU/hardware | `<host>/default.nix` | Hardware-specific only |
| Add a new host | Copy victoria as template | Most complete config |
| Test changes | `nix build .#nixosConfigurations.victoria.config.system.build.toplevel --dry-run` | |

## CONVENTIONS

- `default.nix` — NEVER put module toggles here. Hardware/kernel/hostname/stateVersion only.
- `modules.nix` — One flat attrset: `config.tiebe = { ... };`. Imports `../../modules`.
- Two users configured: `tiebe` (primary) and `robbin` (secondary, jupiter+pluto only).

## ANTI-PATTERNS

- Adding module toggles to `default.nix` instead of `modules.nix`
- Forgetting to add new module toggle to ALL relevant hosts' `modules.nix`
- Editing `hardware-configuration.nix` by hand (it's generated)
