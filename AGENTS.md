# Agent Guidelines for Mactoflake Repository

NixOS flake configuration, originally ported from the Arch Linux dotfiles repo at `https://github.com/Xitonight/mactodots` (stow-based). Three hosts are configured: `mactone` (physical desktop), `mactopad` (physical laptop), and `vm` (QEMU test host).

## 1. Build / Deploy / Check Commands

- **Validate flake structure (fast):**
  ```bash
  nix flake show
  ```
- **Deploy locally (on NixOS):**
  ```bash
  nh os switch
  ```
  `nh` reads `NH_OS_FLAKE` (set in `modules/system/nh.nix`) so no `--flake` flag is needed. Swap the host name in `flake.nix` or use `nh os switch -- --hostname <host>` for a different target.
- **Deploy remotely (from another machine):**
  ```bash
  nixos-rebuild -- switch \
    --flake .#<host> --impure --target-host xitonight@<host> --ask-sudo-password
  ```
- **Update an input** (do one at a time, never bulk):
  ```bash
  nix flake lock --update-input nixpkgs
  ```
  `nixpkgs` and `home-manager` must stay on the same nixpkgs revision (HM follows nixpkgs).
- **Linting:** `nix run nixpkgs#statix -- check .`
- **Testing:** No automated tests. Verify by deploying and checking the host boots / SSH responds.
- **Flakes only see git-tracked files** — always `git add` new files before building.

## 2. Finding NixOS / Home Manager Options

Use [searchix.ovh](https://searchix.ovh/?query={searchParams}) to look up available options for any NixOS or Home Manager module. For example, to find options for `programs.kitty`, search `programs.kitty` on searchix.ovh. This is the primary way to discover option names, types, and defaults before writing module config.

## 3. Architecture

- **Inputs:** `nixpkgs` (unstable), `home-manager` (follows nixpkgs), `minegrub-theme`, `hyprland`, `firefox-addons`, `zen-browser`, `nix-index-database`. All pinned in `flake.lock`.
- **Home Manager runs as a NixOS module** (`useGlobalPkgs = true`, `useUserPackages = true`), NOT standalone. System + home build atomically in one `nh os switch`.
- **Layout:**
  ```
  flake.nix                # inputs + nixosConfigurations wiring (3 hosts)
  hosts/<name>/            # per-host: default.nix + hardware-configuration.nix
  modules/system/          # shared NixOS-level modules (boot, locale, network, nix, hyprland, audio, bluetooth, kanata, tailscale, fonts, ...)
  modules/home/            # shared Home Manager modules (one concern per file)
  modules/home/<name>/source/  # raw config trees for symlinked configs (nvim, hypr)
  ```

### System modules (`modules/system/`)

Applied as a shared base to every host via `./modules/system/default.nix`. Each host also imports its own `hardware-configuration.nix` and adds host-specific config.

| File | Purpose |
|------|---------|
| `1password.nix` | 1Password CLI + GUI integration |
| `boot.nix` | `mactoflake.boot.loader` option (`grub` \| `systemd-boot`); minegrub theme |
| `locale.nix` | TZ `Europe/Rome`, `en_US.UTF-8` + `it_IT.UTF-8` |
| `network.nix` | NetworkManager + OpenSSH |
| `nix.nix` | Flakes, auto-optimise, registry pin, weekly gc, allowUnfree |
| `nh.nix` | nh (nix helper) convenience wrapper |
| `overlays.nix` | Nixpkgs overlays |
| `packages.nix` | System-wide packages (CLI tools, desktop apps, theming) |
| `fonts.nix` | CaskaydiaCove Nerd Font, Poppins, Noto Emoji, Font Awesome + fontconfig |
| `hyprland.nix` | `mactoflake.hyprland.monitors` option; `programs.hyprland` (withUWSM, xwayland, upstream); xdg portal; polkit; gnome-keyring |
| `audio.nix` | PipeWire full stack (alsa, pulse, jack, wireplumber) + rtkit |
| `bluetooth.nix` | `hardware.bluetooth` (bluez, fast-connect) + `bluetui` |
| `kanata.nix` | `mactoflake.input.kanata` option; uinput/input groups; ships `kanata.kbd` |
| `polkit.nix` | Polkit authentication agent |
| `tailscale.nix` | `mactoflake.network.tailscale` option + enableSSH |
| `cachix.nix` | Substituters (nix-community, hyprland) + trusted keys |
| `nvidia.nix` | NVIDIA driver config (modesetting, open, GSP); imported by `mactone` only |

### Home modules (`modules/home/`)

| File | Approach | Notes |
|------|----------|-------|
| `bat.nix` | `programs.bat` | Cat replacement with syntax highlighting |
| `btop.nix` | `programs.btop.settings` | Full 80+ setting attrset |
| `devenv.nix` | devenv integration | Dev environment manager |
| `eza.nix` | `programs.eza` | Modern ls replacement |
| `fzf.nix` | `programs.fzf` | Fuzzy finder |
| `git.nix` | `programs.git.settings` | Name + email |
| `gtk.nix` | `gtk` HM module | adw-gtk3-dark, Papirus-Dark, Bibata cursor |
| `kitty.nix` | `programs.kitty.settings` + `keybindings` + `extraConfig` | `include colors.conf` for matugen runtime colors |
| `lazygit.nix` | `programs.lazygit` | Terminal UI for git |
| `matugen/` | matugen integration | Material You color generation |
| `mpv.nix` | `programs.mpv` | Media player config |
| `oh-my-posh.nix` | `programs.oh-my-posh` | Cross-shell prompt theme |
| `pay-respects.nix` | pay-respects | `cd` replacement with smart suggestions |
| `qt.nix` | Qt theming | Qt theme configuration |
| `rbw.nix` | `programs.rbw` | Bitwarden CLI (if imported) |
| `rofi/` | rofi config | Application launcher |
| `scripts/` | Custom scripts | Helper scripts |
| `ssh.nix` | SSH config | SSH client configuration |
| `swaync/` | swaync config | Notification daemon |
| `tmux.nix` | `programs.tmux` + `programs.sesh` + `programs.fzf.tmux` | Plugins via `pkgs.tmuxPlugins` |
| `vesktop.nix` | vesktop config | Discord client |
| `xdg.nix` | `xdg.userDirs` | Custom dirs (dl/pics/docs/projects/videos) |
| `yazi.nix` | `programs.yazi` | Terminal file manager |
| `zathura.nix` | `programs.zathura` | PDF viewer |
| `zen.nix` | `programs.zen-browser` (from flake input) | Full profile, addons, bookmarks, workspaces |
| `zoxide.nix` | `programs.zoxide` | Smart cd replacement |
| `zsh.nix` | `programs.zsh` | Shell config + plugins |
| `nvim/` | `mkOutOfStoreSymlink` | See symlink strategy below |
| `hypr/` | `mkOutOfStoreSymlink` | See symlink strategy below |

### `specialArgs` / `extraSpecialArgs`

- `specialArgs` passes `inputs`, `flakeDir = "/home/xitonight/.mactoflake"`, and `username` to all system modules.
- `extraSpecialArgs` adds `monitorsConfig = config.mactoflake.hyprland.monitors` for home modules.
- Any module can declare `{ inputs, flakeDir, monitorsConfig, ... }:` and access these.

- **Host branching** is done with `lib.mkIf` against the hostname, not by guessing at runtime.

## 4. Config Strategy: Nix Modules vs Out-of-Store Symlinks

Two strategies are used, depending on the tool:

### Structured Nix modules (preferred when available)

Tools with a Home Manager module (`programs.<x>.enable` + `.settings`) are configured in Nix. This gives type-checking, merge semantics, and atomic rebuilds. Examples: `btop`, `kitty`, `git`, `tmux`, `gtk`, `zen-browser`.

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

## 5. Code Style (Nix)

- **Module granularity:** one concern per file (e.g. `network.nix`, `boot.nix`). Never dump everything into one file.
- **Prefer `programs.<x>.enable` / `services.<x>.enable` modules** over raw config files when a NixOS/HM module exists.
- **Use `mkOutOfStoreSymlink`** for large/native configs that are better maintained in their own language (see §4).
- **Stateful data never goes in the flake** (browser profiles, `~/.local/share`, wallpapers, matugen-generated color files). Config only.
- **`allowUnfree = true`** is set globally in `modules/system/nix.nix`.
- **`stateVersion` is `26.05`** for both system and home — must match the install version and never change.
- **No hardcoded `/usr/lib` or `/usr/bin` paths** — NixOS has no FHS. Use `pkgs.<name>` and let Nix resolve store paths.
- **No comments** unless strictly necessary.

## 6. Key Facts

- **Developer / daily-driver host:** `mactone` — physical desktop, NixOS, Hyprland + NVIDIA.
- **Hosts:**
  - `mactone` — physical desktop, NixOS, Hyprland, NVIDIA, tailscale.
  - `mactopad` — physical laptop, NixOS, Hyprland, tailscale.
  - `vm` — QEMU/libvirt, UEFI boot, test/throwaway host.
- All machines run Tailscale and are reachable via their hostname over the tailnet.
- **Timezone:** `Europe/Rome`; locale `en_US.UTF-8` with `it_IT.UTF-8` regional formatting.
- **Hyprland** uses Lua as its native config language (since v0.55). The `hl.*` calls are the official Lua API — no rewrite or wrapper package needed.
