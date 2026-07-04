# Migration: Xidots -> Mactoflake

Porting `~/.xidots` (Arch + stow) into this NixOS flake. Two hosts are live:
`vm` (QEMU test VM) and `mactopad` (physical laptop with Hyprland desktop).

---

## Porting Status

### Ported to Home Manager modules (structured Nix config)

| Tool | Module | Approach |
|------|--------|----------|
| bat | `modules/home/bat.nix` | `programs.bat` — theme=base16 (config file replaces `BAT_THEME` env var) |
| btop | `modules/home/btop.nix` | `programs.btop.settings` — full 80+ setting attrset |
| delta | `modules/home/git.nix` | `programs.delta` — line-numbers, navigate, side-by-side, syntax-theme=base16 |
| eza | `modules/home/eza.nix` | `programs.eza` — zsh integration, icons=auto, colors=always (creates `eza` shell alias) |
| fzf | `modules/home/fzf.nix` | `programs.fzf` — zsh + tmux shell integration |
| git | `modules/home/git.nix` | `programs.git` — name + email |
| gtk | `modules/home/gtk.nix` | `gtk` HM module — adw-gtk3-dark, Papirus-Dark, Bibata cursor |
| kitty | `modules/home/kitty.nix` | `programs.kitty` — settings, keybindings, extraConfig (`include colors.conf` for matugen) |
| lazygit | `modules/home/lazygit.nix` | `programs.lazygit.settings` — quitOnTopLevelReturn, theme |
| mpv | `modules/home/mpv.nix` | `programs.mpv` — hwdec=auto-safe, volume 75, keep-open, osd-font=CaskaydiaCove |
| oh-my-posh | `modules/home/oh-my-posh.nix` | `programs.oh-my-posh` — async prompt, git segment, transient prompt, execution time |
| opencode | `modules/home/opencode/` | `programs.opencode` — model, plugin, keybinds |
| pay-respects | `modules/home/pay-respects.nix` | `programs.pay-respects` — zsh integration, AI suggestions disabled |
| qt | `modules/home/qt.nix` | `qt` HM module — qt5ct/qt6ct with matugen color scheme, Papirus-Dark icons |
| rbw | `modules/home/rbw.nix` | `programs.rbw` — Bitwarden CLI |
| swaync | `modules/home/swaync/` | `services.swaync.settings` (config.json) + `style` (CSS with `@import` for matugen colors) + component CSS via `xdg.configFile` |
| tmux | `modules/home/tmux.nix` | `programs.tmux` + `programs.sesh` + `programs.fzf.tmux` — plugins via `pkgs.tmuxPlugins` |
| xdg dirs | `modules/home/xdg.nix` | `xdg.userDirs` — custom dirs |
| yazi | `modules/home/yazi.nix` | `programs.yazi` — zsh integration (`y()` cwd wrapper); theme via matugen `theme.toml` |
| zathura | `modules/home/zathura.nix` | `programs.zathura` — options, mappings, `extraConfig` (`include colors.zathurarc` for matugen) |
| zen-browser | `modules/home/zen.nix` | `programs.zen-browser` (flake input) — full profile, addons, bookmarks, workspaces |
| zoxide | `modules/home/zoxide.nix` | `programs.zoxide` — `--cmd cd`, zsh integration |
| zsh | `modules/home/zsh.nix` | `programs.zsh` — plugins (fzf-tab, zsh-vi-mode, fast-syntax-highlighting), autosuggestions, vi mode, aliases, functions, OMZ sudo widget, sesh/fzf integration, auto-attach tmux |

### Ported via out-of-store symlinks (`mkOutOfStoreSymlink`)

These configs are kept as raw source files in the repo and symlinked into
`~/.config/`. Edits take effect immediately without a rebuild. See AGENTS.md §3
for the rationale.

| Config | Source dir | Symlink target | Why |
|--------|-----------|----------------|-----|
| Neovim | `modules/home/nvim/source/` | `~/.config/nvim` | NvChad + lazy.nvim manages 40+ plugins; Nix-managed plugins would be a massive rewrite with no benefit |
| Hyprland | `modules/home/hypr/source/` | `~/.config/hypr/` (per-file) | Lua API (`hl.*`) is Hyprland's native config language; no benefit to porting to Nix |
| matugen | `modules/home/matugen/source/` | `~/.config/matugen` | `config.toml` + 19 color templates for kitty, hyprland, gtk, rofi, swaync, cava, zathura (colors-only), yazi, etc.; template-heavy, maintained natively in TOML |
| rofi | `modules/home/rofi/source/` | `~/.config/rofi` | 7 `.rasi` profiles + shared `defaults.rasi`; relies on `@import` of matugen-generated `colors.rasi` at runtime; no benefit to porting to Nix |
| fsh | `modules/home/fsh/source/` | `~/.config/fsh` | fast-syntax-highlighting theme (`base16.ini`); runtime theme for zsh's fsh plugin |

### Ported as system-level NixOS modules

| Module | Contents |
|--------|----------|
| `boot.nix` | `mactoflake.boot.loader` option (grub \| systemd-boot); minegrub theme |
| `locale.nix` | TZ `Europe/Rome`, `en_US.UTF-8` + `it_IT.UTF-8` |
| `network.nix` | NetworkManager + OpenSSH |
| `nix.nix` | Flakes, auto-optimise, registry pin, weekly gc, allowUnfree |
| `shell.nix` | `programs.zsh.enable` + `programs.fish.enable`; default shell = zsh |
| `fonts.nix` | CaskaydiaCove Nerd Font, Poppins, Noto Emoji, Font Awesome + fontconfig |
| `hyprland.nix` | `mactoflake.hyprland.monitors` option; `programs.hyprland` (withUWSM, xwayland, upstream); xdg portal; polkit; gnome-keyring |
| `audio.nix` | PipeWire full stack (alsa, pulse, jack, wireplumber) + rtkit |
| `bluetooth.nix` | `hardware.bluetooth` (bluez, fast-connect) + `bluetui` |
| `kanata.nix` | `mactoflake.input.kanata` option; uinput/input groups; ships `kanata.kbd` |
| `tailscale.nix` | `mactoflake.network.tailscale` option + enableSSH |
| `cachix.nix` | Substituters (nix-community, hyprland) + trusted keys |

### Installed as bare system packages (no HM module yet)

These are in `modules/system/packages.nix` via `environment.systemPackages`.
Some have HM modules available and could be ported for config; others have no
module equivalent.

| Tool | HM module available? | Notes |
|------|---------------------|-------|
| **gh** | `programs.gh` | Removed — never used |
| **delta** | `programs.delta` | Ported — `modules/home/git.nix` |
| **sesh** | `programs.sesh` (already used in tmux.nix) | Also installed as system pkg |
| **fastfetch** | No HM module | Bare package; config not yet shipped |
| **tmuxinator** | No HM module | Bare package |
| **fd, ripgrep, file, killall, rsync, just, wl-clipboard, unzip, zip, wtype, xdg-user-dirs** | No HM module | Pure CLI utilities; no config needed |
| **neovim** | — | Package installed system-wide; config symlinked (see above) |
| **gcc, rustc, cargo, cmake, gnumake** | — | Build toolchains; needed by nvim (blink.cmp) |
| **mpv** | `programs.mpv` | Ported — `modules/home/mpv.nix` |
| **obsidian** | No HM module | Bare package |
| **telegram-desktop** | No HM module | Bare package |
| **cava** | No HM module | Bare package; config is matugen-generated |
| **awww** | No HM module | Installed; wallpaper manager |
| **pywal** | No HM module | Installed |
| **rofi (rofi-emoji, rofi-rbw), swaynotificationcenter** | No HM module | Desktop apps; config symlinked (rofi) or via HM module (swaync); system pkg provides the binary |
| **hyprpolkitagent, cliphist, udiskie, hyprshot, grim, slurp, playerctl, brightnessctl, ddcutil, wiremix** | No HM module | Desktop utilities; launched via hyprland config |
| **papirus-icon-theme, qt5/qt6 wayland, nwg-look** | No HM module | Theming; qt config handled via `qt.nix` HM module |
| **stow** | — | Removed — legacy Arch migration leftover, no longer needed |

---

## Remaining Work

### CLI tools to HM modules (LOW)

_(None remaining — bat, delta, gh all resolved.)_

### GUI app configs (LOW)

_(None remaining — mpv ported.)_

### nvidia.nix (MEDIUM — reserved for future `macto` host)

`modules/system/nvidia.nix` exists with modesetting/open/gsp config and
kernelParams but is **intentionally not imported** by `vm` or `mactopad` (both
non-NVIDIA). It is reserved for the future `macto` desktop host and will be
wired behind a `mactoflake.gpu.nvidia` option when that host is added. Not
pending work for current hosts.

### sops-nix (LOW)

Secrets management not yet added. Add `sops-nix` as a flake input for API keys
and other secrets.

### Fish HM module (LOW)

`programs.fish.enable` is set system-wide but there's no HM config. If keeping
fish as an alternative shell, a parallel config would need to be written fresh
(no fish config exists in xidots).

---

## Decisions (resolved)

- **[D1/D2] Hyprland:** Lua is the native config language (since v0.55). The `hl.*`
  calls are Hyprland's official Lua API — **no wrapper to package**. Ship the Lua
  config as-is via `mkOutOfStoreSymlink`.
- **[D3] `awww`:** wallpaper manager (renamed from `swww`), upstream
  https://codeberg.org/LGFae/awww, **on nixpkgs**.
- **[D4] Local derivations:** nearly everything is on nixpkgs — `awww`, `matugen`,
  `bibata` cursors, `pay-respects`, `sesh`, `kanata`, `tmux-floax`.
  **`zen-browser`** comes from a flake input.
  Only **`walogram`** would need a local derivation (not yet ported).
- **[D5] Neovim:** ship the NvChad config dir via `mkOutOfStoreSymlink`; let
  lazy.nvim + mason.nvim bootstrap at first launch.
- **[D6] Git:** configure via HM `programs.git`. Identity: name `Xitonight`,
  email `xitonight@gmail.com`.
- **[D7] GTK theme:** use `adw-gtk3-dark` (skip `AxMat` — deprecated).
- **[D8] zoxide:** keep replacing `cd` (`--cmd cd`).
- **[D9] pay-respects:** keep installed with AI suggestions **disabled**.
- **[D10] Hostnames:** laptop = **`mactopad`**, desktop = **`macto`** (future),
  mini pc = **`mactomini`** (future). `vm` stays as the throwaway test host.
- **[D11] fish:** enabled alongside zsh; zsh remains the default login shell.

---

## Config strategy summary

| Strategy | When to use | Examples |
|----------|-------------|----------|
| **HM module** (`programs.<x>.enable` + `.settings`) | Tool has a Home Manager module | btop, kitty, git, delta, tmux, gtk, rbw, lazygit, mpv, swaync, zen-browser, zsh, fzf, zoxide, oh-my-posh, pay-respects, qt, opencode, eza, yazi, zathura, bat |
| **Out-of-store symlink** (`mkOutOfStoreSymlink`) | Large configs or configs better maintained in their native language (Lua, Vimscript, TOML, Rasi) | neovim, hyprland, matugen, rofi, fsh |
| **System package** (`environment.systemPackages`) | CLI utilities with no config, or tools awaiting HM module port | fd, ripgrep, ... |
| **Not in flake** (stateful runtime data) | Browser profiles, wallpapers, generated color files | `.zen/`, `colors.conf`, `~/.local/share` |
