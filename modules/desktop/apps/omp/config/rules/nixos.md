---
description: This host runs NixOS; use Nix to obtain missing packages and flakes for project toolchains.
alwaysApply: true
---

# NixOS host

This machine runs NixOS. Packages live in the Nix store and are exposed on
`PATH` through `/run/current-system/sw/bin`. Distribution package managers
(`apt`, `dnf`, `pacman`) and an FHS `/usr/bin` toolchain are not available.

- You are allowed to use any Nix command needed to obtain a missing package,
  without asking first when the change is ephemeral: `nix run nixpkgs#<attr> -- …`,
  `nix shell nixpkgs#<attr> -c …`, `nix build nixpkgs#<attr>`,
  `nix develop`, and `nix search nixpkgs <name>`.
- Never reach for `apt`, `dnf`, `pacman`, or `brew`. A missing command usually
  means its attribute is not on `PATH`; resolve it with Nix.
- Projects MAY carry their own `flake.nix`. Use `devShells.default` for the
  project toolchain and `packages.default` when the project builds, then run
  commands through `nix develop -c …`.
- Format Nix code with `nix fmt` (alejandra) and validate flakes with
  `nix flake check`.
- Persisting a package into the user profile (`nix profile add …`) or changing
  system configuration is a state change: do it only when the task requires
  it, and report what changed. This repo's system configuration lives at
  `/persist/etc/nixos` and is applied with
  `sudo nixos-rebuild switch --flake .#<host>`.
- Repository guidance wins over this rule. In `/persist/etc/nixos`, do not add
  new flake inputs or system packages without explicit permission; propose the
  change instead.
- Some upstream tools hardcode `/usr/bin/...` helpers. On NixOS, pass a
  Nix-provided absolute path (for example `${pkgs.util-linux}/bin/prlimit`)
  rather than assuming `/usr/bin`.
