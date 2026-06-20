# Agent Guidelines for Flakey Repository

This is a NixOS flake configuration, being ported from the Arch Linux dotfiles repo at `~/.xidots` (stow-based). It is developed and built on an Arch host and deployed remotely to a QEMU VM (and eventually real hardware: `archpad` laptop, a desktop).

## 1. Build / Deploy / Check Commands

- **Validate flake structure (fast):**
  ```bash
  nix flake show
  ```
- **Deploy to the VM (builds on Arch, pushes closure, activates on VM):**
  ```bash
  nix run nixpkgs#nixos-rebuild -- switch \
    --flake .#vm --target-host xitonight@192.168.122.136 --use-remote-sudo
  ```
  First build downloads the entire NixOS system closure (slow); subsequent builds are incremental. The VM user `xitonight` has passwordless sudo via `security.sudo.wheelNeedsPassword = false` (VM-only convenience).
- **Update an input** (do one at a time, never bulk):
  ```bash
  nix flake lock --update-input nixpkgs
  ```
  `nixpkgs` and `home-manager` must stay on the same nixpkgs revision (HM follows nixpkgs).
- **Formatting:** `nix run nixpkgs#nixfmt-classic -- .` (format) / `-- --check .` (check).
- **Linting:** `nix run nixpkgs#statix -- check .`
- **Testing:** No automated tests. Verify by deploying and checking the VM boots / SSH responds.

## 2. Architecture

- **Inputs:** `nixpkgs` (unstable) + `home-manager` (follows nixpkgs). Both pinned in `flake.lock`.
- **Home Manager runs as a NixOS module** (`useGlobalPkgs = true`), NOT standalone. System + home build atomically in one `nixos-rebuild`.
- **Layout:**
  ```
  flake.nix              # inputs + nixosConfigurations wiring
  hosts/<name>/          # per-host: default.nix + hardware-configuration.nix
  modules/system/        # shared NixOS-level modules (boot, locale, network, nix)
  modules/home/          # shared Home Manager modules
  ```
  The flake applies `./modules/system` as a shared base to every host. Each host imports its own `hardware-configuration.nix` and adds host-specific config (hostname, user groups, stateVersion).
- **`specialArgs` passes `inputs`** down to all modules, so any module can declare `{ inputs, ... }:` and access flakes (used in `modules/system/nix.nix` for the registry pin).
- **Host branching** is done with `lib.mkIf` against the hostname, not by guessing at runtime.

## 3. Code Style (Nix)

- **Formatting (nixfmt-classic):** 2-space indent.
- **Module granularity:** one concern per file (e.g. `network.nix`, `boot.nix`). Never dump everything into one file.
- **Prefer `programs.<x>.enable` / `services.<x>.enable` modules** over raw config files when a NixOS/HM module exists. Only drop to `home.file` / `xdg.configFile` for tools with no module.
- **Stateful data never goes in the flake** (browser profiles, `~/.local/share`, wallpapers). Config only.
- **`allowUnfree = true`** is set globally in `modules/system/nix.nix`.
- **`stateVersion` is `26.05`** for both system and home — must match the install version and never change.
- **No hardcoded `/usr/lib` or `/usr/bin` paths** — NixOS has no FHS. Use `pkgs.<name>` and let Nix resolve store paths.

## 4. Project Context (the port from Xidots)

The source of truth for what needs porting is `~/.xidots` (Arch + stow). Porting is phased:

- **Phase 0 (DONE):** Flake skeleton, VM host boots from the flake, Nix daemon + gc + registry pin.
- **Phase 1 (NEXT):** Shell + terminal + editor core — zsh (zinit, oh-my-posh, vi-mode), kitty, tmux (+TPM plugins via `pkgs.tmuxPlugins`), neovim (ship config dir, let lazy.nvim bootstrap), bat, eza, fzf, zoxide, git+delta, gh, lazygit, mise, btop.
- **Phase 2:** Theming + fonts + GUI apps — GTK theme `AxMat`, qt5ct/qt6ct, Bibata cursors, nerd fonts, rofi, swaync, yazi, zathura, mpv, fastfetch, bitwarden, obsidian, telegram-desktop.
- **Phase 3:** Hyprland + Wayland stack — `programs.hyprland.enable`, awww (custom derivation), portals, polkit, udiskie, cliphist. **Note:** the source hyprland config is lua-based (`hl.*` API) — either keep the wrapper as a package or port to native hyprlang/`wayland.windowManager.hyprland`.
- **Phase 4:** System services — kanata (home-row mods, needs `uinput`/`input` groups), pipewire, bluetooth, tailscale, docker, networking.
- **Phase 5:** Dev toolchains — mise for language versions, clang via nixpkgs, `texlive.combined.scheme-full`, pnpm. Keep ESP-IDF + Android SDK as manual installs.
- **Phase 6:** Real hosts (`archpad`, desktop) + sops-nix for secrets.

### Known porting gotchas (from the source config)
- `awww` (custom bar) and `matugen` likely need local derivations in a `packages/` dir.
- Hardcoded Arch paths in `.zshrc` (`/usr/lib/polkit-gnome/...`, `/usr/bin/qmake`, TexLive `/usr/local/texlive/2025/...`) must be removed/repointed.
- The `.zen/` browser profile is pure state — exclude it from the flake entirely.
- TPM plugins should move to `pkgs.tmuxPlugins.*` (sensible, yank, vim-tmux-navigator exist); floax may not be packaged.

## 5. Key Facts

- **Developer host:** Arch Linux (`xitonight`), Nix 2.34 via `pacman -S nix`, daemon-managed (`nix-daemon.service`), flakes enabled.
- **Target VM:** QEMU/libvirt, UEFI boot, `192.168.122.136`, user `xitonight`, NixOS 26.05.
- **Timezone:** `Europe/Rome`; locale `en_US.UTF-8` with `it_IT.UTF-8` regional formatting.
- **Nix flakes only see git-tracked files** — always `git add` new files before building, or the flake won't find them.
