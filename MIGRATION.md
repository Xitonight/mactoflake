# Migration Plan: Xidots -> Flakey

Porting `~/.xidots` (Arch + stow) into this NixOS flake. Source of truth = the
inventory below (derived from the live `~/.xidots` tree).

> Note: the initial inventory got several facts wrong. Corrections are folded in
> below — Hyprland uses **Lua as its native config language** since v0.55
> (hyprlang is the deprecated one); `awww` is a **wallpaper manager** (renamed
> `swww`), not a bar; and most AUR packages are already on nixpkgs.

---

## Status

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Flake skeleton, VM host boots, nix daemon + gc + registry pin | **DONE** (deployed) |
| 1 | Shell + terminal + editor core | **DONE** (deployed to VM) |
| 2 | Theming + fonts + GUI apps | TODO |
| 3 | Hyprland + Wayland stack | TODO |
| 4 | System services (kanata, pipewire, bluetooth, tailscale, docker) | TODO |
| 5 | Dev toolchains (mise, clang, texlive, pnpm) | TODO |
| 6 | Real hosts (`mactopad`, `macto`, `mactomini`) + sops-nix | TODO |

### What exists in the flake today (Phase 0)

- `flake.nix` — one host `vm`; HM as a NixOS module; `specialArgs` passes `inputs`.
- `hosts/vm/` — hostname, user `xitonight`, passwordless sudo (VM-only), qemu-guest, `stateVersion = "26.05"`.
- `modules/system/` — `boot`, `locale`, `network` (networkmanager + openssh), `nix` (registry pin, weekly gc, `trusted-users = [ root xitonight ]`, experimental-features, allowUnfree).
- `modules/home/default.nix` — **empty shell** (username, homeDirectory, stateVersion, `home-manager.enable`). Nothing ported yet.

### Conventions to follow (from AGENTS.md)

- 2-space indent, `nixfmt-classic`. One concern per file.
- Prefer `programs.<x>.enable` / `services.<x>.enable` modules; only drop to `xdg.configFile` / `home.file` when no module exists.
- No hardcoded `/usr/...` paths (NixOS has no FHS). Use `pkgs.<name>`.
- `git add` new files before building, or the flake won't see them.
- `home-manager` runs as a NixOS module (`useGlobalPkgs = true`).

---

## Decisions (resolved)

- **[D1/D2] Hyprland:** Lua is the native config language (since v0.55). The `hl.*`
  calls are Hyprland's official Lua API — **no wrapper to package**. Ship the Lua
  config as-is.
- **[D3] `awww`:** wallpaper manager (renamed from `swww`), upstream
  https://codeberg.org/LGFae/awww, **on nixpkgs**. `ambxst` is deprecated ->
  **skip entirely** (to be removed from the Arch dots too).
- **[D4] Local derivations:** nearly everything is on nixpkgs — `awww`, `matugen`,
  `bibata` cursors, `pay-respects`, `sesh`, `kanata`, `impala`, `tmux-floax`.
  Only **`walogram`** needs a local derivation. **`zen-browser`** comes from a
  flake input: https://github.com/0xc000022070/zen-browser-flake.
- **[D5] Neovim:** ship the NvChad config dir verbatim to `~/.config/nvim`; let
  lazy.nvim + mason.nvim bootstrap at first launch. A Rust toolchain is added for
  the `blink.cmp` build step. (Help available on request if first-run issues.)
- **[D6] Git:** configure via HM `programs.git` + delta. Identity: name `Xitonight`,
  email `xitonight@gmail.com` (GitHub: `Xitonight`).
- **[D7] GTK theme:** skip `AxMat` entirely (slated for deletion); use `adw-gtk3-dark`.
- **[D8] zoxide:** keep replacing `cd` (`--cmd cd`).
- **[D9] pay-respects:** keep installed with AI suggestions **disabled**.
- **[D10] Hostnames:** laptop = **`mactopad`** (was `archpad`), desktop = **`macto`**,
  mini pc (maybe) = **`mactomini`**. `vm` stays as the throwaway test host. Phases
  1-2 target `vm` (headless/TUI) since it has no GUI.

**Phase 1 is unblocked — all decisions resolved (git: Xitonight <xitonight@gmail.com>).**

---

## Phase 1 -- Shell + terminal + editor core

Target host: `vm` (headless). Everything here is Home Manager config. No GUI.

### Proposed `modules/home/` layout

```
modules/home/
  default.nix            # imports all sub-modules
  shell/
    zsh.nix
  terminal/
    kitty.nix
    tmux.nix
  editor/
    neovim.nix
  cli/
    git.nix              # fresh git config
    tools.nix            # bat, eza, fzf, zoxide, fd, ripgrep, gh, lazygit, mise, btop, fastfetch
  fonts.nix              # fontconfig (headless-safe)
```

### 1.1 Shell -- zsh (`shell/zsh.nix`)

Source: `dots/.zshrc`, `dots/.zsh/completions/_sesh`.

- `programs.zsh.enable` + `enableVteIntegration`; ship `.zshrc` body as HM initExtra / module options where possible.
- **zinit** plugin manager (bootstraps itself): plugins = `zsh-completions`, `fzf-tab`, `zsh-autosuggestions`, `fast-syntax-highlighting`, `zsh-vi-mode`, OMZ `sudo` snippet. *(zinit clones at runtime — default: keep zinit.)*
- **oh-my-posh** prompt via `programs.oh-my-posh.enable` + `xdg.configFile` for `oh-my-posh/config.toml`.
- **vi-mode** (`zsh-vi-mode`): system clipboard via `wl-copy`, mode cursors, history binds.
- **Integrations:** fzf (`fzf --zsh`), zoxide (`--cmd cd`, kept), mise activate, pay-respects (AI disabled).
- **History:** HISTSIZE 10000, `~/.zsh_history`, dedup/share.
- **MANPAGER** = `bat -l man -p`, `BAT_THEME=base16`.
- **Aliases/functions to port:** `p()` fzf-jump `~/Projects`, `cppath`, `y()` yazi wrapper, `sesh-sessions`, `mksesh`, eza `ls/l/la/ll/ld/lt*` aliases, `-h/--help`->bat, `v/vim`->nvim, `j`->just, `open`->xdg-open, `C`->wl-copy.
- **Aliases to DROP (Arch-only):** `yay`/pacman aliases, `upmirrors` (reflector), `slowwifi`/`resetwifi` (tc netem on a specific iface).
- **Env vars to set via `home.sessionVariables`:** XDG dirs, `BAT_THEME`, `MANPAGER`, `PNPM_HOME`, `GOPATH`, `ANDROID_HOME`, `EDITOR/VISUAL=nvim`. *(drop the TexLive/`/usr/local/...` PATH lines — handled by Phase 5)*
- **Hardcoded paths to fix:** see table below.

### 1.2 Terminal -- kitty (`terminal/kitty.nix`)

Source: `dots/.config/kitty/kitty.conf`.

- `programs.kitty.enable` + `settings` for font 17, padding 14, no bell, no decorations, cursor trail, remote-control (`listen_on unix:/tmp/kitty`).
- Ctrl+Shift+HJKL raw-xterm keybinds (for nvim).
- `colors.conf` is **matugen-generated** — don't ship it now (Phase 2). Ship a static fallback or omit until matugen runs.

### 1.3 Terminal -- tmux (`terminal/tmux.nix`)

Source: `dots/.config/tmux/tmux.conf`.

- `programs.tmux.enable` + custom config: prefix `C-Space`, status on top (2 lines), vi mode, base-index 1, renumber.
- Floax popup (`M-f`), sesh picker (`M-s`), sesh last (`M-l`), lazygit popup (`M-g`).
- **Plugins via `pkgs.tmuxPlugins` (all on nixpkgs):** `sensible`, `vim-tmux-navigator`, `yank`, `floax`.

### 1.4 Editor -- neovim (`editor/neovim.nix`)

Source: entire `dots/.config/nvim/` (NvChad v2.5 + lazy.nvim).

- `programs.neovim.enable` (+ `neovim` package); ship the **whole `nvim/` tree** via `xdg.configFile."nvim".source = ./nvim;` (copy the dir into the module).
- Let `lazy.nvim` bootstrap plugins (network access at first launch) and `mason.nvim` manage the 18 LSPs + formatters/linters.
- Provide runtime tools that mason expects to *not* manage: `git` (already present), `kitty` (for remote control), `tmux`, `zathura` (Phase 2), latex tools (Phase 5).
- `rustc`/`cargo` for the `blink.cmp` build step.
- `xdg.configFile` the `.stylua.toml` too.

### 1.5 CLI tools (`cli/tools.nix`, `cli/git.nix`)

| Tool | Approach |
|------|----------|
| bat | `programs.bat.enable` (+ theme via env, no config dir in source) |
| eza | package + zsh aliases |
| fzf | `programs.fzf.enable` (+ `fzf --zsh` integration) |
| zoxide | `programs.zoxide.enable` (`--cmd cd`) |
| fd, ripgrep | packages |
| gh | `programs.gh.enable` |
| lazygit | `programs.lazygit.enable` + ship `lazygit/config.yml` |
| mise | `programs.mise.enable` + ship `mise/config.toml` (`node = "lts"`) |
| btop | `programs.btop.enable` + ship `btop/btop.conf` |
| fastfetch | package + config dir (none in source) |
| git/delta | `programs.git` fresh (name/email D6) + `programs.git.delta.enable` |
| sesh | package + ship `sesh/sesh.toml` |
| tmuxinator | package (+ drop hardcoded `.tmuxinator.yml` project root) |

### Phase 1 exit criteria

VM rebuilds; `zsh` launches with prompt + plugins (after zinit bootstrap); `nvim`
opens and bootstraps lazy/mason; tmux + kitty config present. Verify over SSH.

---

## Phase 2 -- Theming + fonts + GUI apps

Still HM-driven where possible. **matugen is the keystone** — it regenerates
~15 color files on wallpaper change. Most color files are gitignored/generated,
so nothing works until matugen runs.

### 2.1 Fonts + fontconfig (`fonts.nix`)

- `fonts.packages` (system): `CaskaydiaCove Nerd Font` (cascadia-code), `Poppins`,
  `noto-fonts-emoji`, font-awesome, awesome-terminal-fonts, nerd-fonts-symbols.
- `xdg.configFile."fontconfig/fonts.conf"`: monospace->CaskaydiaCove, serif/sans->Poppins.
- **Missing from source pkg list: add `papirus-icon-theme`** (used in qt5ct/gtk/rofi).

### 2.2 Theming engine -- matugen + awww

- `matugen` and `awww` are both **on nixpkgs** (no local derivations).
- Ship `matugen/config.toml` + `templates/` via `xdg.configFile`.
- Rework template **output paths** that point at `/usr/share/walogram/...` and use
  `sudo chown` (see hardcoded table) to nix-store-aware equivalents.

### 2.3 GTK / Qt

- `gtk` HM module: theme `adw-gtk3-dark` (packaged), iconTheme `Papirus-Dark`,
  cursorTheme `Bibata-Modern-Classic` size 24, font `Sans 14`. (**`AxMat` skipped** — slated for deletion.)
- qt5ct/qt6ct: ship configs via `xdg.configFile`; **fix hardcoded `color_scheme_path`** -> relative/store path. Add `qt5ct`/`qt6ct` + `qt5-wayland`/`qt6-wayland`.
- Cursor: `bibata` cursors from nixpkgs.

### 2.4 GUI apps

| App | Approach |
|-----|----------|
| rofi | `programs.rofi.enable` + ship `rofi/*.rasi`; add `rofi-emoji`, `rofi-rbw` |
| swaync | `services.swaync.enable` + ship `config.json`/`style.css` |
| yazi | `programs.yazi.enable` (colors are matugen-generated) |
| zathura | `programs.zathura.enable` + ship `zathurarc` (vimtex viewer) |
| mpv | `programs.mpv.enable` + ship `mpv.conf` (`loop=inf`) |
| fastfetch | (Phase 1 pkg) + config |
| bitwarden | package + window rule (Phase 3) |
| obsidian | package + nvim `obsidian.nvim` notes path |
| telegram | package + walogram theme (matugen post_hook) |
| zen-browser | flake input https://github.com/0xc000022070/zen-browser-flake; `.zen/` profile = pure state (exclude entirely) |
| cava | matugen-generated config |

---

## Phase 3 -- Hyprland + Wayland stack

Hyprland uses **Lua as its native config language** (since v0.55; hyprlang is
deprecated). The `hl.*` calls in the config are Hyprland's official Lua API, so
the existing `hypr/` tree ships as-is — **no rewrite, no wrapper package.**

### System modules (`modules/system/hyprland.nix`)

- `programs.hyprland.enable`.
- Portals: `xdg.portal` with `xdg-desktop-portal-hyprland` + `gtk`.
- `security.polkit.enable` + polkit-gnome agent (fix `/usr/lib/polkit-gnome/...` -> `pkgs.polkit_gnome` store path).
- `services.udiskie` (rework the `/run/media/` + stow hack).
- `cliphist` + `wl-clipboard` (`wl-paste --watch cliphist store`).

### Home config (HM)

- Ship the whole Lua tree: `xdg.configFile."hypr".source = ./hypr;` (incl. `hyprland.lua` + `source/*.lua`).
- `awww` (wallpaper manager, nixpkgs) as exec-once daemon; `awww img` sets wallpaper.
- Drop the `ambxst` config entirely (deprecated).
- Provide runtime binaries the config calls: kitty, btop, rofi, swaync-client,
  playerctl, wpctl, hyprshot, cliphist, wl-paste, ddcutil, slurp, jq, etc.

### Host branching

`hyprland.lua` currently shells out to `hostname` to branch. On NixOS, branch via
the hostname in the host module (`lib.mkIf (config.networking.hostName == "mactopad")`),
per AGENTS.md — not runtime `hostname` calls. (`mactopad`: eDP-1, scale 1.33;
`macto`: nvidia + HDMI-A-1 -> `nvidia.lua`.)

---

## Phase 4 -- System services (system-level modules)

New `modules/system/` files:

| File | Contents |
|------|----------|
| `kanata.nix` | `services.kanata`; home-row mods from `kanata.kbd`; `users.groups.uinput`, add user to `input`+`uinput`, udev `99-input.rules` |
| `audio.nix` | `services.pipewire` (alsa, pulse) + **wireplumber** (missing from source list) |
| `bluetooth.nix` | `hardware.bluetooth` + `blueman` (missing from source list) |
| `tailscale.nix` | `services.tailscale.enable` |
| `docker.nix` | `virtualisation.docker` + buildx + compose |
| `networking.nix` | (already partly in `network.nix`) iwd/resolved as needed |

Kanata currently runs as a **user** systemd unit with hardcoded `/usr/bin/sh` +
`/usr/local/bin:/usr/bin:/bin` PATH -> rework to a NixOS `services.kanata` system
service (cleaner) or HM `systemd.user.services.kanata` with store paths.

---

## Phase 5 -- Dev toolchains (HM + system)

| Tool | Approach |
|------|----------|
| mise | `programs.mise` (Phase 1) for node + project-level langs |
| clang | `pkgs.clang` (+ `clangd` for nvim) |
| texlive | `pkgs.texlive.combined.scheme-full` -> **drop the `/usr/local/texlive/2025` PATH hack** |
| pnpm | package + `PNPM_HOME` session var (no `/home/...` hardcode -> `$HOME`) |
| Go/Rust/etc | via mise or direct pkgs; `rustc`/`cargo` for blink build |
| ESP-IDF | **manual** (`~/.esp`, `espidf` alias sources export.sh) |
| Android SDK | **manual** (`ANDROID_HOME`, android-studio, scrcpy) |

---

## Phase 6 -- Real hosts + secrets

- `hosts/mactopad/` (laptop) + `hosts/macto/` (nvidia desktop) + `hosts/mactomini/` (mini pc, optional) + `hardware-configuration.nix` each.
- `sops-nix` input for secrets (API keys, etc.).
- Remove VM-only `security.sudo.wheelNeedsPassword = false` on real hardware.
- Refactor host-specific bits out of shared `modules/` using `lib.mkIf` on hostname.

---

## Hardcoded paths to fix (consolidated)

| Source | Path | Fix |
|--------|------|-----|
| `.zshrc:1` | `/home/xitonight/.xidots` | drop (no xidots on NixOS) |
| `.zshrc:96` | `/etc/pacman.d/mirrorlist` | drop (reflector alias) |
| `.zshrc:252` | `/home/xitonight/.local/share/pnpm` | `PNPM_HOME` via `$HOME` |
| `.zshrc:260` | `/usr/local/texlive/2025/bin/...` | Phase 5: `texlive.combined` |
| `.zshrc:14` | `xitonight@mini` | tailscale host -> host-specific |
| `hypr/env.lua:23` | `/usr/bin/qmake` | drop |
| `hypr/autostart.lua:2` | `/usr/lib/polkit-gnome/...` | `pkgs.polkit_gnome` |
| `hypr/autostart.lua:3` | `/run/media/` + stow | rework udiskie |
| `hypr/colors.lua:2` | `/home/.../3-rain_world.png` | state -> keep out of flake |
| `matugen/config.toml` | `/usr/share/walogram/...`, `sudo chown` | rework templates |
| `qt5ct.conf:2`, `qt6ct.conf:2` | `/home/.../colors/matugen.conf` | store/relative path |
| `kanata.service:6,9` | `/usr/local/bin:/usr/bin:/bin`, `/usr/bin/sh` | system service |
| `tmux.conf:1` | `/usr/local/bin:/bin:/usr/bin` | drop (let NixOS set PATH) |
| `.tmuxinator.yml` | `/home/xitonight/.xidots` | drop / make relative |

No `/opt/` references anywhere.

---

## Local-derivation candidates (`packages/`)

- **`walogram`** — the only one needing a local derivation (Telegram theme via matugen).
- **`zen-browser`** — not a derivation; add as a **flake input** (https://github.com/0xc000022070/zen-browser-flake).
- Everything else (`awww`, `matugen`, `bibata`, `pay-respects`, `sesh`, `kanata`, `impala`, `tmux-floax`) is already on nixpkgs.
- `ambxst` is dropped (deprecated).

---

## Suggested execution order

1. Phase 1 (headless TUI) -> build, deploy to VM, verify zsh/nvim/tmux/kitty.
2. Phase 5 dev toolchains (needed for nvim: clangd, texlive, rust for blink).
3. Phase 2 theming/GUI (matugen + awww from nixpkgs).
4. Phase 3 Hyprland (Lua config ships as-is).
5. Phase 4 system services.
6. Phase 6 real hosts (`mactopad`, `macto`, `mactomini`) + sops.

Each phase = one or more commits, one deploy, one verification pass.
