# Migration: Xidots -> Mactoflake

Porting `~/.xidots` (Arch + stow) into this NixOS flake. Two hosts are live:
`vm` (QEMU test VM) and `mactopad` (physical laptop with Hyprland desktop).

---

## Porting Status

### Ported to Home Manager modules (structured Nix config)

| Tool | Module | Approach |
|------|--------|----------|
| btop | `modules/home/btop.nix` | `programs.btop.settings` — full 80+ setting attrset |
| git | `modules/home/git.nix` | `programs.git` — name + email |
| gtk | `modules/home/gtk.nix` | `gtk` HM module — adw-gtk3-dark, Papirus-Dark, Bibata cursor |
| kitty | `modules/home/kitty.nix` | `programs.kitty` — settings, keybindings, extraConfig (`include colors.conf` for matugen) |
| rbw | `modules/home/rbw.nix` | `programs.rbw` — Bitwarden CLI |
| tmux | `modules/home/tmux.nix` | `programs.tmux` + `programs.sesh` + `programs.fzf.tmux` — plugins via `pkgs.tmuxPlugins` |
| xdg dirs | `modules/home/xdg.nix` | `xdg.userDirs` — custom dirs |
| zen-browser | `modules/home/zen.nix` | `programs.zen-browser` (flake input) — full profile, addons, bookmarks, workspaces |

### Ported via out-of-store symlinks (`mkOutOfStoreSymlink`)

These configs are kept as raw source files in the repo and symlinked into
`~/.config/`. Edits take effect immediately without a rebuild. See AGENTS.md §3
for the rationale.

| Config | Source dir | Symlink target | Why |
|--------|-----------|----------------|-----|
| Neovim | `modules/home/nvim/source/` | `~/.config/nvim` | NvChad + lazy.nvim manages 40+ plugins; Nix-managed plugins would be a massive rewrite with no benefit |
| Hyprland | `modules/home/hypr/source/` | `~/.config/hypr/` (per-file) | Lua API (`hl.*`) is Hyprland's native config language; no benefit to porting to Nix |

### Ported as system-level NixOS modules

| Module | Contents |
|--------|----------|
| `boot.nix` | `flakey.boot.loader` option (grub \| systemd-boot); minegrub theme |
| `locale.nix` | TZ `Europe/Rome`, `en_US.UTF-8` + `it_IT.UTF-8` |
| `network.nix` | NetworkManager + OpenSSH |
| `nix.nix` | Flakes, auto-optimise, registry pin, weekly gc, allowUnfree |
| `shell.nix` | `programs.zsh.enable` + `programs.fish.enable`; default shell = zsh |
| `fonts.nix` | CaskaydiaCove Nerd Font, Poppins, Noto Emoji, Font Awesome + fontconfig |
| `hyprland.nix` | `flakey.hyprland.monitors` option; `programs.hyprland` (withUWSM, xwayland, upstream); xdg portal; polkit; gnome-keyring |
| `audio.nix` | PipeWire full stack (alsa, pulse, jack, wireplumber) + rtkit |
| `bluetooth.nix` | `hardware.bluetooth` (bluez, fast-connect) + `bluetui` |
| `kanata.nix` | `flakey.input.kanata` option; uinput/input groups; ships `kanata.kbd` |
| `tailscale.nix` | `flakey.network.tailscale` option + enableSSH |
| `cachix.nix` | Substituters (nix-community, hyprland) + trusted keys |

### Installed as bare system packages (no HM module yet)

These are in `modules/system/packages.nix` via `environment.systemPackages`.
Some have HM modules available and could be ported for shell integrations /
config; others have no module equivalent.

| Tool | HM module available? | Notes |
|------|---------------------|-------|
| **bat** | `programs.bat` | Could set theme, enable shell integrations |
| **eza** | `programs.eza` | Could enable aliases |
| **fzf** | `programs.fzf` | Could enable shell integrations, keybindings |
| **zoxide** | `programs.zoxide` | Could enable shell integrations (`--cmd cd`) |
| **gh** | `programs.gh` | Could configure settings |
| **lazygit** | `programs.lazygit` | Could ship config |
| **delta** | via `programs.git.delta` | Already installed; wire into git module |
| **oh-my-posh** | `programs.oh-my-posh` | Could enable + ship config |
| **pay-respects** | No HM module | Bare package only |
| **sesh** | `programs.sesh` (already used in tmux.nix) | Also installed as system pkg |
| **fastfetch** | No HM module | Bare package; config not yet shipped |
| **opencode** | No HM module | Bare package |
| **fd, ripgrep, file, killall, rsync, just, wl-clipboard, unzip, zip, wtype** | No HM module | Pure CLI utilities; no config needed |
| **neovim** | — | Package installed system-wide; config symlinked (see above) |
| **gcc, rustc, cargo, cmake, gnumake** | — | Build toolchains; needed by nvim (blink.cmp) |
| **rofi** | `programs.rofi` | Installed with rofi-emoji plugin; no config shipped yet |
| **swaynotificationcenter** | `services.swaync` | Installed; no config shipped yet |
| **yazi** | `programs.yazi` | Installed; no config shipped yet |
| **zathura** | `programs.zathura` | Installed; no config shipped yet |
| **mpv** | `programs.mpv` | Installed; no config shipped yet |
| **obsidian** | No HM module | Bare package |
| **telegram-desktop** | No HM module | Bare package |
| **cava** | No HM module | Bare package; config is matugen-generated |
| **matugen** | No HM module | Installed; templates not yet shipped |
| **awww** | No HM module | Installed; wallpaper manager |
| **pywal** | No HM module | Installed |
| **hyprpolkitagent, cliphist, udiskie, hyprshot, grim, slurp, playerctl, brightnessctl, ddcutil, wiremix** | No HM module | Desktop utilities; launched via hyprland config |
| **papirus-icon-theme, qt5ct, qt6ct, qt5/qt6 wayland, nwg-look** | No HM module | Theming; qt5ct/qt6ct config not shipped |
| **stow** | — | Legacy from Arch migration; can be removed |

---

## Remaining Work

### zsh Home Manager module (HIGH)

Currently only `programs.zsh.enable` at the system level. The user runs the raw
`.zshrc` from xidots. To port:

- **zinit** plugin manager: `zsh-completions`, `fzf-tab`, `zsh-autosuggestions`,
  `fast-syntax-highlighting`, `zsh-vi-mode`, OMZ `sudo` snippet (Esc-Esc for sudo).
- **oh-my-posh** prompt via `programs.oh-my-posh.enable` + config.
- **Aliases:** eza `ls/l/la/ll/ld/lt*`, `-h/--help` -> bat, `v/vim` -> nvim,
  `j` -> just, `open` -> xdg-open, `C` -> wl-copy, `p()` fzf-jump, `y()` yazi wrapper.
- **Env vars:** `BAT_THEME`, `MANPAGER`, `EDITOR/VISUAL=nvim`, `PNPM_HOME`, `GOPATH`.
- **Drop Arch-only aliases:** `yay`/pacman, `upmirrors` (reflector),
  `slowwifi`/`resetwifi` (tc netem).

### CLI tools to HM modules (MEDIUM)

`bat`, `eza`, `fzf`, `zoxide`, `gh`, `lazygit`, `oh-my-posh` — all have HM
modules available. Porting them enables shell integrations and structured config.

### GUI app configs (MEDIUM)

`rofi` (`.rasi` files), `swaync` (JSON + CSS), `yazi`, `zathura`, `mpv` — all
installed as packages but have no config shipped. Each has an HM module (except
swaync which uses `services.swaync`).

### matugen templates (MEDIUM)

matugen is installed but its `config.toml` and `templates/` directory are not
shipped. These generate color files for kitty (`colors.conf`), rofi, cava, and
other tools on wallpaper change. Ship via `xdg.configFile`.

### nvidia.nix (MEDIUM)

`modules/system/nvidia.nix` exists with modesetting/open/gsp config and
kernelParams but is **not imported**. Needs wiring behind a `flakey.gpu.nvidia`
option and enabling in `hosts/mactopad/default.nix`.

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
| **HM module** (`programs.<x>.enable` + `.settings`) | Tool has a Home Manager module | btop, kitty, git, tmux, gtk, rbw, zen-browser |
| **Out-of-store symlink** (`mkOutOfStoreSymlink`) | Large configs or configs better maintained in their native language (Lua, Vimscript) | neovim, hyprland |
| **System package** (`environment.systemPackages`) | CLI utilities with no config, or tools awaiting HM module port | bat, eza, fzf, rofi, matugen, ... |
| **Not in flake** (stateful runtime data) | Browser profiles, wallpapers, generated color files | `.zen/`, `colors.conf`, `~/.local/share` |
