# Agent Guidelines for Mactoflake Repository

NixOS flake configuration, originally ported from the Arch Linux dotfiles repo at `~/.xidots` (stow-based). Two hosts are deployed: `vm` (QEMU test VM) and `mactopad` (physical laptop).

## 1. Build / Deploy / Check Commands

- **Validate flake structure (fast):**
  ```bash
  nix flake show
  ```
- **Deploy to a host (builds on Arch, pushes closure, activates on target):**
  ```bash
  nix run nixpkgs#nixos-rebuild -- switch \
    --flake .#vm --impure --target-host xitonight@192.168.122.136 --elevate=sudo
  ```
  Swap `.#vm` and the `--target-host` for other hosts. Both hosts have passwordless sudo via `security.sudo.wheelNeedsPassword = false`.
- **Update an input** (do one at a time, never bulk):
  ```bash
  nix flake lock --update-input nixpkgs
  ```
  `nixpkgs` and `home-manager` must stay on the same nixpkgs revision (HM follows nixpkgs).
- **Formatting:** `nix run nixpkgs#nixfmt -- .` (format) / `-- --check .` (check).
  Note: `nixfmt-classic` has been removed from nixpkgs — use `nixfmt` (RFC 166 style) instead.
- **Linting:** `nix run nixpkgs#statix -- check .`
- **Testing:** No automated tests. Verify by deploying and checking the host boots / SSH responds.
- **Flakes only see git-tracked files** — always `git add` new files before building.

## 2. Architecture

- **Inputs:** `nixpkgs` (unstable), `home-manager` (follows nixpkgs), `minegrub-theme`, `hyprland`, `firefox-addons`, `zen-browser`. All pinned in `flake.lock`.
- **Home Manager runs as a NixOS module** (`useGlobalPkgs = true`, `useUserPackages = true`), NOT standalone. System + home build atomically in one `nixos-rebuild`.
- **Layout:**
  ```
  flake.nix                # inputs + nixosConfigurations wiring (2 hosts)
  hosts/<name>/            # per-host: default.nix + hardware-configuration.nix
  modules/system/          # shared NixOS-level modules (boot, locale, network, nix, hyprland, audio, bluetooth, kanata, tailscale, fonts, ...)
  modules/home/            # shared Home Manager modules (one concern per file)
  modules/home/<name>/source/  # raw config trees for symlinked configs (nvim, hypr)
  ```

### System modules (`modules/system/`)

Applied as a shared base to every host via `./modules/system/default.nix`. Each host also imports its own `hardware-configuration.nix` and adds host-specific config.

| File | Purpose |
|------|---------|
| `boot.nix` | `mactoflake.boot.loader` option (`grub` \| `systemd-boot`); minegrub theme |
| `locale.nix` | TZ `Europe/Rome`, `en_US.UTF-8` + `it_IT.UTF-8` |
| `network.nix` | NetworkManager + OpenSSH |
| `nix.nix` | Flakes, auto-optimise, registry pin, weekly gc, allowUnfree |
| `shell.nix` | `programs.zsh.enable` + `programs.fish.enable`; default shell = zsh |
| `packages.nix` | System-wide packages (CLI tools, desktop apps, theming — see MIGRATION.md for inventory) |
| `fonts.nix` | CaskaydiaCove Nerd Font, Poppins, Noto Emoji, Font Awesome + fontconfig |
| `hyprland.nix` | `mactoflake.hyprland.monitors` option; `programs.hyprland` (withUWSM, xwayland, upstream); xdg portal; polkit; gnome-keyring |
| `audio.nix` | PipeWire full stack (alsa, pulse, jack, wireplumber) + rtkit |
| `bluetooth.nix` | `hardware.bluetooth` (bluez, fast-connect) + `bluetui` |
| `kanata.nix` | `mactoflake.input.kanata` option; uinput/input groups; ships `kanata.kbd` |
| `tailscale.nix` | `mactoflake.network.tailscale` option + enableSSH |
| `cachix.nix` | Substituters (nix-community, hyprland) + trusted keys |

`nvidia.nix` exists but is **not imported** — dead code pending wiring behind an option. (It will be used for mactone host)

### Home modules (`modules/home/`)

| File | Approach | Notes |
|------|----------|-------|
| `btop.nix` | `programs.btop.settings` | Full 80+ setting attrset |
| `git.nix` | `programs.git.settings` | Name + email |
| `gtk.nix` | `gtk` HM module | adw-gtk3-dark, Papirus-Dark, Bibata cursor |
| `kitty.nix` | `programs.kitty.settings` + `keybindings` + `extraConfig` | `include colors.conf` for matugen runtime colors |
| `rbw.nix` | `programs.rbw` | Bitwarden CLI |
| `tmux.nix` | `programs.tmux` + `programs.sesh` + `programs.fzf.tmux` | Plugins via `pkgs.tmuxPlugins` |
| `xdg.nix` | `xdg.userDirs` | Custom dirs (dl/pics/docs/projects/videos) |
| `zen.nix` | `programs.zen-browser` (from flake input) | Full profile, addons, bookmarks, workspaces |
| `nvim/` | `mkOutOfStoreSymlink` | See symlink strategy below |
| `hypr/` | `mkOutOfStoreSymlink` | See symlink strategy below |

### `specialArgs` / `extraSpecialArgs`

- `specialArgs` passes `inputs` and `flakeDir = "/home/xitonight/.mactoflake"` to all system modules.
- `extraSpecialArgs` adds `monitorsConfig = config.mactoflake.hyprland.monitors` for home modules.
- Any module can declare `{ inputs, flakeDir, monitorsConfig, ... }:` and access these.

- **Host branching** is done with `lib.mkIf` against the hostname, not by guessing at runtime.

## 3. Config Strategy: Nix Modules vs Out-of-Store Symlinks

Two strategies are used, depending on the tool:

### Structured Nix modules (preferred when available)

Tools with a Home Manager module (`programs.<x>.enable` + `.settings`) are configured in Nix. This gives type-checking, merge semantics, and atomic rebuilds. Examples: `btop`, `kitty`, `git`, `tmux`, `gtk`, `rbw`, `zen-browser`.

### Out-of-store symlinks (for large or natively-maintained configs)

Bigger configs, or configs that are better maintained in their native language (Lua, Vimscript), are **not** translated to Nix. Instead they are kept as raw source files in the repo and symlinked into `~/.config/` via `config.lib.file.mkOutOfStoreSymlink`. This means:

- Edits to the source files take effect immediately (no rebuild needed).
- The files live in the git-tracked repo tree under `modules/home/<name>/source/`.
- HM manages the symlink; the content is outside the Nix store.

Current symlinked configs:

| Config | Source dir | Symlink target | Why symlinked |
|--------|-----------|----------------|----------------|
| Neovim | `modules/home/nvim/source/` | `~/.config/nvim` | NvChad + lazy.nvim manages 40+ plugins; Nix-managed plugins would be a massive rewrite with no benefit |
| Hyprland | `modules/home/hypr/source/` | `~/.config/hypr/` (per-file) | Lua API (`hl.*`) is Hyprland's native config; no benefit to porting to Nix |

### Stateful runtime data (never in flake)

Wallpapers, matugen-generated color files (`colors.conf`), and `~/.local/share` are pure state and excluded from the flake entirely.

## 4. Code Style (Nix)

- **Formatting (`nixfmt`, RFC 166):** 2-space indent.
- **Module granularity:** one concern per file (e.g. `network.nix`, `boot.nix`). Never dump everything into one file.
- **Prefer `programs.<x>.enable` / `services.<x>.enable` modules** over raw config files when a NixOS/HM module exists.
- **Use `mkOutOfStoreSymlink`** for large/native configs that are better maintained in their own language (see §3).
- **Stateful data never goes in the flake** (browser profiles, `~/.local/share`, wallpapers, matugen-generated color files). Config only.
- **`allowUnfree = true`** is set globally in `modules/system/nix.nix`.
- **`stateVersion` is `26.05`** for both system and home — must match the install version and never change.
- **No hardcoded `/usr/lib` or `/usr/bin` paths** — NixOS has no FHS. Use `pkgs.<name>` and let Nix resolve store paths.
- **No comments** unless strictly necessary.

## 5. Key Facts

- **Developer host:** Arch Linux (`xitonight`), Nix via `pacman`, daemon-managed, flakes enabled.
- **Hosts:**
  - `vm` — QEMU/libvirt, UEFI boot, `192.168.122.136`, user `xitonight`, test/throwaway host.
  - `mactopad` — physical laptop, deployed via SSH, Hyprland + full desktop.
- **Timezone:** `Europe/Rome`; locale `en_US.UTF-8` with `it_IT.UTF-8` regional formatting.
- **Hyprland** uses Lua as its native config language (since v0.55). The `hl.*` calls are the official Lua API — no rewrite or wrapper package needed.

## 6. Remaining Work

See `MIGRATION.md` for the full porting status, including what's already done and what's still TODO. Key remaining items:

- **zsh HM module** — currently only `programs.zsh.enable` system-wide; no zinit/oh-my-posh/vi-mode/aliases ported yet (user runs the raw `.zshrc` from xidots for now).
- **CLI tools to HM modules** — bat, eza, fzf, zoxide, gh, oh-my-posh are installed as bare packages; could gain HM modules for shell integrations and config.
- **GUI app configs** — rofi, swaync, yazi, zathura, mpv, matugen templates are not yet shipped.
- **nvidia.nix** — exists but not wired.
- **sops-nix** — secrets management not yet added.
