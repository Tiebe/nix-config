# Desktop Apps Modules

## OVERVIEW

22 application modules under `tiebe.desktop.apps.<name>`. Each folder contains `default.nix` + `darlings.nix`.

## MODULE CATALOG

| Module | Complexity | Notes |
|--------|-----------|-------|
| bitwarden | simple | Password manager |
| discord | medium | Krisp audio patcher, applied to BOTH tiebe + robbin users |
| firefox | complex | `overrideAttrs` + `wrapProgram --set HOME` for evict-darlings |
| httptoolkit | simple | HTTP debugging proxy |
| lmstudio | simple | LLM interface |
| legcord | simple | Discord client |
| localsend | simple | Local file sharing |
| media | simple | Media players |
| minecraft | simple | Game |
| obsidian | simple | Notes |
| office | simple | LibreOffice |
| opencode | complex | Tauri build from source (`inputs.opencode`), custom derivation |
| opendeck | simple | Stream deck — **loose file** (`opendeck.nix`, not in subfolder) |
| parsec | simple | Remote desktop |
| piper | simple | Mouse config (libratbag) |
| protonmail | simple | Email client |
| rofi | complex | **Most complex app** (349L) — cheatsheet PDF generation + desktop entries |
| spotify | simple | Music |
| steam | complex | `extraEnv.HOME` override, dual-path darlings with activation scripts |
| thunar | simple | File manager |
| vscode | simple | VSCodium |
| zed | simple | Editor |

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new app module | Create `<name>/default.nix` + `<name>/darlings.nix` | Follow docker module as template |
| Import new module | `modules/desktop/apps/default.nix` | Add to imports list |
| Enable for a host | `hosts/<host>/modules.nix` | `tiebe.desktop.apps.<name>.enable = true` |
| evict-darlings HOME wrapping | See `firefox/default.nix` | `overrideAttrs` + `wrapProgram` pattern |
| Dual-path persistence | See `steam/darlings.nix` | `if evictCfg.enable then ... else ...` |
| mkOutOfStoreSymlink + activation | See `opencode/darlings.nix` | `lib.hm.dag.entryBefore ["writeBoundary"]` |

## CONVENTIONS (specific to apps)

- Options namespace: `tiebe.desktop.apps.<name>`
- Every darlings.nix must handle evict-darlings path branching when persisting user data
- Use `config.lib.file.mkOutOfStoreSymlink` inside home-manager (requires `config` in lambda args)
- Always pre-create `/persist` target dirs via `home.activation` when using `mkOutOfStoreSymlink`

## ANTI-PATTERNS

- Forgetting `darlings.nix` companion file (even if empty, it MUST exist)
- Using `systemd.tmpfiles.rules` for paths under `/users/` — causes permission errors
- Missing activation script for `mkOutOfStoreSymlink` targets — broken symlinks on first boot

## KNOWN ISSUES

- `opendeck.nix` is a loose file, not in a subfolder — legacy pattern
- `rofi/` exists here AND in `desktop/hyprland/programs/` — duplicate coverage
