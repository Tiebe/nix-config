# Service Modules

## OVERVIEW

23 service modules under `tiebe.services.<name>`. Each folder contains `default.nix` + `darlings.nix` except legacy loose files noted below.

## MODULE CATALOG

| Module | Complexity | Notes |
|--------|-----------|-------|
| bitfocus-companion | complex | Custom `package.nix` — Electron/Yarn build from source |
| boinc | simple | **Loose file** (`boinc.nix`, not in subfolder) |
| cachix | simple | Binary cache |
| devenv | simple | Dev environments |
| docker | simple | Container runtime — canonical module template |
| fingerprint | simple | fprintd |
| gpg | medium | YubiKey agent, SSH integration |
| lorri | simple | Nix shell manager |
| nextcloud | simple | Self-hosted cloud |
| nova-chatmix | medium | SteelSeries Nova Pro Wireless ChatMix daemon (headless user service + udev rule) |
| openvpn | simple | VPN client |
| podman | simple | Container runtime (rootless) |
| printing | simple | CUPS |
| ratbagd | simple | Mouse daemon |
| ssh-server | simple | OpenSSH |
| sunshine | medium | Game streaming server |
| variety | simple | Wallpaper manager |
| vr | simple | VR headset support |
| waydroid | medium | Android container runtime with `/var/lib/waydroid` persistence for darlings |
| winapps | complex | Docker + RDP Windows app integration |
| windows | complex | **VFIO GPU passthrough** — `scopedHooks.nix` + `vm.nix` (3 files) |
| zerogravity | complex | Custom Rust build — **orphaned** (not imported by `services/default.nix`) |

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new service | Create `<name>/default.nix` + `<name>/darlings.nix` | Follow `docker/` as template |
| Import new service | `modules/services/default.nix` | Add to imports list |
| Custom package build | See `bitfocus-companion/package.nix` | Electron/Yarn pattern |
| VFIO passthrough | `windows/` | 3-file structure: default + scopedHooks + vm |
| systemd + darlings | Add `after = ["persist.mount"]; requires = ["persist.mount"];` | Required for persist-dependent services |

## CONVENTIONS (specific to services)

- Options namespace: `tiebe.services.<name>`
- systemd services needing persistence MUST declare `requires/after = ["persist.mount"]`
- Empty darlings.nix stubs are valid and required

## ANTI-PATTERNS

- Forgetting `persist.mount` dependency on services that read from `/persist`
- `with lib;` in module scope — `services/windows/scopedHooks.nix` is a known legacy violation

## KNOWN ISSUES

- `zerogravity/` is not imported by `services/default.nix` — orphaned module
- `boinc.nix` is a loose file, not in a subfolder — legacy pattern
- `windows/scopedHooks.nix` uses `with lib; let` — legacy, do not replicate
