# 🌾 mactoflake

> My personal NixOS + Hyprland flake. Keyboard-driven, heavily themed, and built to be read.

This is a **declarative NixOS configuration** managed as a flake, with [Home Manager](https://nix-community.github.io/home-manager/) wired in as a NixOS module. It runs [Hyprland](https://hyprland.org/) (configured in its native Lua API since v0.55) on top of three hosts: a desktop, a laptop, and a throwaway VM.

---

> [!WARNING]
> ## This is NOT a copy-paste config
>
> This flake is **opinionated and personal**. It will not boot correctly on your machine without changes — hardware differs, SSH keys differ, monitor outputs differ, and dozens of modules are imported **by default**. It is meant to be **read, understood, and tailored**, not cloned and switched.
>
> That said, it is **highly modular** and well-suited as a base or reference for anyone willing to spend some time bending it to their needs. If you can read Nix, you can make this yours.

---

## Table of contents

- [Prerequisites & install location](#prerequisites--install-location)
- [The `username` and `flakeDir` variables](#the-username-and-flakedir-variables)
- [Creating your own host](#creating-your-own-host)
- [Custom options](#custom-options)
- [Important: impure symlinks & the `--impure` flag](#important-impure-symlinks--the---impure-flag)
- [Neovim: the bootstrap ritual 🧙](#neovim-the-bootstrap-ritual-)
- [Zen Browser](#zen-browser)
- [1Password (highly recommended)](#1password-highly-recommended)
- [The terminal experience](#the-terminal-experience)
- [Hyprland](#hyprland)
- [Kanata (home-row mods)](#kanata-home-row-mods)
- [Theming: GTK, Qt & matugen](#theming-gtk-qt--matugen)
- [Bootloader: Minecraft-flavoured 🧱](#bootloader-minecraft-flavoured-)
- [Fonts](#fonts)
- [Cachix](#cachix)
- [Development: devenv](#development-devenv)
- [Keyboard-first philosophy](#keyboard-first-philosophy)
- [Credits](#credits)

---

## Prerequisites & install location

You need a machine running (or installing) NixOS with flakes enabled.

The flake expects to live at:

```
/home/<your-user>/.mactoflake
```

This is **not mandatory** — it can live anywhere — but `flakeDir` is declared in [`flake.nix`](flake.nix) and threaded through every module that builds out-of-store symlinks (nvim, hyprland, matugen, etc.). Keeping it there means everything Just Works™ out of the box, and `nh` (the nix helper, see [`modules/system/nh.nix`](modules/system/nh.nix)) reads `NH_OS_FLAKE` so you can deploy with a bare `nh os switch` (or better, `nos`). If you clone elsewhere, just update `flakeDir` in `flake.nix`.

> [!NOTE]
> Of course, flakeDir will be wired in AFTER you rebuild, so the first time you rebuild using the flake you'll still have to pass the right path with the usual `sudo nixos-rebuild switch --flake /path/to/the/flake#<your_hostname>`

---

## The `username` and `flakeDir` variables

At the top of [`flake.nix`](flake.nix) there are a handful of `let` bindings:

| Variable | Default | What it does |
|----------|---------|--------------|
| `username` | `"xitonight"` | Passed to **every** system and home module via `specialArgs`/`extraSpecialArgs`. The HM user, the `users.users.<name>` declaration, git identity, group memberships — basically everything follows this. **Change it once and the whole flake re-keys to your user.** |
| `flakeDir` | `"/home/${username}/.mactoflake"` | Absolute path to the repo. Used to build out-of-store symlinks. |
| `papersDir` | `"$XDG_PICTURES_DIR/papers"` | Where wallpapers are picked from by the rofi wallpaper script. Change freely. |
| `email` | `"xitonight@gmail.com"` | Used for the git commit identity. |

Changing `username` is the single most impactful edit you'll make when tailoring this to yourself.

---

## Creating your own host

When tailoring this flake, you should **create your own host** rather than reusing mine (or at least modify it to suit your needs). Each host lives in `hosts/<name>/` and needs two files:

- **`hardware-configuration.nix`** — generated on the machine itself by running:
  ```bash
  nixos-generate-config
  ```
  This inspects your hardware and spits out a `hardware-configuration.nix` (and a `configuration.nix` you can ignore). Drop the generated `hardware-configuration.nix` into `hosts/<name>/`. If you're unsure when/how to run this during a NixOS install, the [NixOS manual](https://nixos.org/manual/nixos/stable/) walks through the whole install flow.

- **`default.nix`** — imports its own `hardware-configuration.nix` and pulls in the shared system base. The simplest version just imports **almost everything**:

  ```nix
  # hosts/<your-host>/default.nix
  {
    imports = [
      ./hardware-configuration.nix
      ../../modules/system          # the shared base (everything by default)
      # ../../modules/system/nvidia.nix  # add host-specific modules as needed
    ];

    # Declare any machine-specific config here. I put all my custom
    # mactoflake.* options in here, but you can set whatever you need.
    mactoflake.boot.loader = "systemd-boot";
    mactoflake.hyprland.monitors = [ /* ... */ ];

    system.stateVersion = "26.05";
  }
  ```

Importing `../../modules/system` gives you the whole shared base in one line; import individual modules instead (or in addition) when you need host-specific ones like `nvidia.nix`. This is where you declare your per-machine `mactoflake.*` options (and any other host-specific config).

Finally, **register the host in `flake.nix`** via the `mkHost` helper, e.g. at [`flake.nix:109-111`](flake.nix):

```nix
# The // simply merges the configurations created,
# it's needed only if you use multiple hosts
nixosConfigurations = (mkHost "vm") // (mkHost "mactopad") // (mkHost "mactone");
```

Just add your own `(mkHost "<your-host>")` to that set and it's wired in.

---

## Custom options

Almost all system modules in [`modules/system/`](modules/system/) are imported **by default** via [`modules/system/default.nix`](modules/system/default.nix). To opt *out* of one, remove its import line. The toggleable / configurable behaviour lives behind a set of custom `mactoflake.*` options — set them per-host in `hosts/<name>/default.nix`:

| Option | Type | Default | Effect |
|--------|------|---------|--------|
| `mactoflake.boot.loader` | `"grub"` \| `"systemd-boot"` | `"systemd-boot"` | Which bootloader to use. |
| `mactoflake.boot.silent-boot` | bool | `true` | Quiets the kernel/initrd/console during boot (`quiet splash loglevel=3`, etc.). |
| `mactoflake.boot.plymouth` | bool | `false` | Enables the Plymouth boot splash with the **Minecraft** theme. Pairs best with `silent-boot`. |
| `mactoflake.boot.grub.efiInstallAsRemovable` | bool | `false` | Installs GRUB to the fallback removable EFI path instead of relying on NVRAM. Handy on boards that wipe EFI vars. |
| `mactoflake.git.signingKey` | string (null) | `null` | SSH public key used to sign git commits/tags via the **1Password** SSH agent. Set per-host. |
| `mactoflake.input.kanata.enable` | bool | `false` | Enables [kanata](https://github.com/jtroo/kanata) with a **home-row mods** layout (`a/s/d/f/j/k/l` → `meta/alt/shift/ctrl`). Great for trying the layout with a single toggle. |
| `mactoflake.hyprland.monitors` | list of monitor attrs | `[]` | Per-host monitor setup. Passed to Home Manager to generate `monitors.lua`. Empty list falls back to the repo's own `monitors.lua`. |
| `mactoflake.network.tailscale.enable` | bool | `false` | Enables Tailscale. |
| `mactoflake.network.tailscale.enableSSH` | bool | `false` | Enables Tailscale SSH (`--ssh`). |
| `mactoflake.power.enable` | bool | `false` | Enables TLP power/battery management. |
| `mactoflake.power.chargeThresholds.{start,stop}` | int 0–100 (null) | `null` | Battery charge thresholds for long-term health (mainly ThinkPads). Ignored on unsupported hardware. |
| `mactoflake.virtualization.enable` | bool | `false` | Enables the libvirt + QEMU/KVM stack with virt-manager. |
| `mactoflake.virtualization.enableUSBRedirection` | bool | `true` | SPICE USB passthrough to VMs. |

<details>
<summary>Example: setting options per-host</summary>

```nix
# hosts/mactone/default.nix
mactoflake.boot = {
  loader = "grub";
  silent-boot = true;
  plymouth = true;
  grub.efiInstallAsRemovable = true;
};

mactoflake.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...";

mactoflake.input.kanata.enable = true;

mactoflake.hyprland.monitors = [
  { output = "HDMI-A-1"; mode = "1920x1080@75"; scale = 1; }
];
```

</details>

---

## Important: impure symlinks & the `--impure` flag

Neovim and Hyprland configs are **not** translated to Nix. Instead, the raw source trees (Lua) live under `modules/home/<name>/source/` and are symlinked into `~/.config/` via `config.lib.file.mkOutOfStoreSymlink`:

| Config | Source | Symlink target |
|--------|--------|----------------|
| Neovim | [`modules/home/nvim/source/`](modules/home/nvim/source/) | `~/.config/nvim` |
| Hyprland | [`modules/home/hypr/source/`](modules/home/hypr/source/) | `~/.config/hypr/` (per-file) |

Because `mkOutOfStoreSymlink` resolves paths **outside** the Nix store, building is impure.

> [!IMPORTANT]
> If you deploy with raw `nixos-rebuild`, you **must** pass `--impure`:
>
> ```bash
> nixos-rebuild switch --flake .#<host> --impure
> ```
>
> `nh os switch` handles this transparently and is the recommended way to deploy locally.

The upside is huge: **any edit you make to the nvim or hyprland Lua source takes effect immediately — no rebuild needed.** Just save the file.

---

## Neovim: the bootstrap ritual 🧙

The Neovim config is built on [NvChad](https://nvchad.com/) + [lazy.nvim](https://github.com/folke/lazy.nvim) managing 40+ plugins. **It will not work out of the box.** Opening `nvim` immediately after first installing the flake will crash during plugin bootstrap because some third-party plugins need a couple of passes to settle their cache.

You must bootstrap it once:

<details>
<summary><b>👉 The first-time bootstrap (click to expand)</b></summary>

```bash
# 1. Remove the symlink (this does NOT touch the source in the flake).
rm -rf ~/.config/nvim

# 2. Clone the NvChad starter and open nvim so it can bootstrap its cache.
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# 3. Once plugins finish installing, close nvim.

# 4. Remove the starter again so HM can re-symlink your real config.
rm -rf ~/.config/nvim

# 5. Rebuild so the flake's config is symlinked back in.
nh os switch        # or: nixos-rebuild switch --flake .#<host> --impure
```

</details>

> [!CAUTION]
> **If you already ran `nvim` before doing the bootstrap** (and it broke), the cached/garbled state will keep breaking it. Clear everything and redo the ritual:
>
> ```bash
> rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
> ```
>
> Then run the bootstrap steps above.

---

## Zen Browser

The browser of choice is [Zen Browser](https://zen-browser.app/), configured declaratively in [`modules/home/zen.nix`](modules/home/zen.nix) via the [zen-browser-flake](https://github.com/0xc000022070/zen-browser-flake) Home Manager module.

It's a **complete but personal** setup: custom search engines (incl. a Searchix shortcut `@nix`), a curated set of disabled default shortcuts, vertical tabs on the right, compact UI, pinned workspaces, and addons (uBlock Origin, Vimium, 1Password). Use it as a base to learn from — expect to rewrite a lot of it.

> [!NOTE]
> ### IDs are randomly generated
> Almost every `id = "..."` in the Zen config (workspaces, bookmarks, shortcuts) is a random UUID. If you add your own, generate fresh ones:
>
> ```bash
> uuidgen
> ```
>
> If you want to **regenerate a workspace** (so Zen treats it as new and rebuilds it), just change one character of its `id` — **not** the dashes — and that's enough.

> [!TIP]
> ### "My extensions didn't install after rebuild!"
> They did. They're just not *active*. Go to `about:addons` (or Settings → Extensions) and enable them manually — this is normal Firefox/Zen behaviour.
>
> ### Workspace ordering
> Workspace position is a bit buggy. I tried to enforce a custom order and couldn't get it reliable, so no magic fix to offer there — reorder them by drag in the UI.

---

## 1Password (highly recommended)

[1Password](https://1password.com/) is enabled system-wide ([`modules/system/1password.nix`](modules/system/1password.nix)) with GUI + CLI and the Zen browser allow-listed for integration. **I cannot recommend this enough.** It unlocks:

- 🔑 **SSH key management** — your SSH keys live in 1Password and are served by its built-in SSH agent. No plaintext keys on disk.
- ✍️ **Signed git commits** — set your SSH public key via `mactoflake.git.signingKey` (per-host) and the git module ([`modules/home/git.nix`](modules/home/git.nix)) signs every commit/tag using 1Password's `op-ssh-sign`.
- 🌐 **A fantastic Zen/Firefox extension** — autofill everywhere, bundled into the Zen addons.

This is the single biggest quality-of-life upgrade in the whole flake.

---

## The terminal experience

The terminal is where this setup shines. A few highlights (all keyboard-driven, see [`modules/home/tmux.nix`](modules/home/tmux.nix)):

- **`tmux`** with a custom **two-line status bar** at the top — tuned to pair visually with NvChad's statusline.
- **`tmux-floax`** — press <kbd>Alt</kbd>+<kbd>F</kbd> to pop a floating scratch terminal.
- **`sesh`** — the tmux session manager (my saviour). Press <kbd>Alt</kbd>+<kbd>S</kbd> to open an `fzf`-powered session picker built on recently/frequently visited directories (via `zoxide`), with live `eza` previews. <kbd>Alt</kbd>+<kbd>L</kbd> jumps to the last session. You can pre-configure sessions with custom enter/preview commands in Nix.
- **`lazygit`** — press <kbd>Alt</kbd>+<kbd>G</kbd> to open it in a tmux popup over whatever pane you're in.
- Window navigation with <kbd>Alt</kbd>+<kbd>H</kbd>/<kbd>L</kbd>, direct pane resizing with <kbd>Ctrl</kbd>+<kbd>H/J/K/L</kbd>, and `vim-tmux-navigator` for seamless pane↔nvim splits.

Plus a shell decked out with `zsh`, `fzf`, `eza`, `bat`, `zoxide`, `yazi`, `btop`, `pay-respects`, and `oh-my-posh`/`starship` prompts.

---

## Hyprland

[Hyprland](https://hyprland.org/) is the window manager, enabled via `programs.hyprland` (with UWSM, xwayland, and the upstream package from the flake input). The config is written in **Hyprland's native Lua API** (`hl.*` calls) under [`modules/home/hypr/source/`](modules/home/hypr/source/), split into focused files: `keybinds.lua`, `windowrules.lua`, `animations.lua`, `input.lua`, `submaps.lua`, `autostart.lua`, and more.

**Per-host monitors** are declared in Nix via `mactoflake.hyprland.monitors` and compiled into a `monitors.lua` that Hyprland imports — so you configure monitors declaratively without touching Lua. Leave the list empty to fall back to the repo's bundled `monitors.lua`.

The keybinds are extensive and submap-heavy. Plan to spend time in [`source/source/keybinds.lua`](modules/home/hypr/source/source/keybinds.lua).

---

## Kanata (home-row mods)

[Kanata](https://github.com/jtroo/kanata) remaps the keyboard at a low level. This flake ships a layout with **home-row mods** (`a/s/d/f/j/k/l` → `meta/alt/shift/ctrl` with tap/hold timing) in [`modules/system/kanata.kbd`](modules/system/kanata.kbd).

Because it's behind a single toggle — `mactoflake.input.kanata.enable` — it's trivial to **try the layout and turn it off** if it's not for you. Zero commitment.

---

## Theming: GTK, Qt & matugen

Both GTK and Qt are themed consistently. On top of that, [**matugen**](https://github.com/InioX/matugen) generates a full **Material You** colour palette from a wallpaper and feeds it into every program that supports custom themes (kitty reads a generated `colors.conf`, Hyprland imports a generated `colors.lua`, etc.).

Wallpaper picking is one keystroke away via the **rofi wallpaper script** ([`modules/home/scripts/rofi-wallpaper.nix`](modules/home/scripts/rofi-wallpaper.nix)): pick an image and matugen runs automatically.

- **Wallpapers location:** `$XDG_PICTURES_DIR/papers` (i.e. `~/Pictures/papers`). Change the `papersDir` variable in `flake.nix` to point elsewhere.
- **Want wallpapers?** I keep a public, contribution-friendly wallpapers repo: **[github.com/Xitonight/papers](https://github.com/Xitonight/papers)** — free to use and add to.

> [!NOTE]
> Generated colour files and wallpapers are **pure state** — they never enter the flake. Only the config that consumes them does.

---

## Bootloader: Minecraft-flavoured 🧱

By default every host uses **systemd-boot**. Switch to GRUB via `mactoflake.boot.loader = "grub"` and you get a thoroughly themed boot experience:

- 🟫 **minegrub-theme** — a Minecraft-style GRUB menu with a pixel splash ("Flakes go brrr") and the Trails & Tales background.
- 🟫 **Minecraft Plymouth theme** — enable with `mactoflake.boot.plymouth = true` to hide kernel logs behind a themed splash. Best paired with `silent-boot`.

Both themes are wired as flake inputs so no manual setup is needed.

---

## Fonts

Fonts are pinned at the system level ([`modules/system/fonts.nix`](modules/system/fonts.nix)) so every app uses the same families where possible:

| Role | Family |
|------|--------|
| Monospace | **CaskaydiaCove Nerd Font** |
| Serif & Sans-serif | **Poppins** |
| Emoji | **Noto Color Emoji** |
| Bonus | **Font Awesome**, **Monocraft** |

These defaults apply to both GTK and Qt apps via `fontconfig`.

---

## Cachix

To avoid building big things (notably Hyprland and nix-community packages) from source, the flake declares binary caches in [`modules/system/cachix.nix`](modules/system/cachix.nix):

- `https://nix-community.cachix.org`
- `https://hyprland.cachix.org`

These kick in automatically on any rebuild *after* the first install. Fair warning: I'm honestly not sure how to leverage them during the **very first** OS install (when the caches aren't in your config yet) — for that initial bootstrap you may end up compiling some packages. Once the system is up, subsequent builds pull binaries as expected.

---

## Development: devenv

[**devenv**](https://devenv.sh/) is already wired up ([`modules/home/devenv.nix`](modules/home/devenv.nix)) and is the recommended way to handle per-project development environments on NixOS.

📖 I won't write a guide here — head to the official wiki: **[devenv.sh](https://devenv.sh/)**.

---

## Keyboard-first philosophy

This setup is **down-heavy on keyboard-only workflows.** Aliases and keybinds are everywhere — in the shell, in tmux, in Hyprland submaps, in Zen, in nvim. If something has a shortcut, it's bound. If you're a mouse-driven person, a lot of muscle memory will need rebuilding; if you live on the keyboard, you'll feel at home.

Take the time to read the keybind files — that's where the real productivity lives.

---

## Credits

Originally ported from my Arch Linux dotfiles (stow-based): **[github.com/Xitonight/mactodots](https://github.com/Xitonight/mactodots)**.

Wallpapers repo: **[github.com/Xitonight/papers](https://github.com/Xitonight/papers)**.

Built on the shoulders of NixOS, Home Manager, Hyprland, NvChad, and the broader nix community.
