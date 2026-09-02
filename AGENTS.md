# Agent Guidelines for Mactoflake Repository

NixOS flake configuration, originally ported from the Arch Linux dotfiles repo at `https://github.com/Xitonight/mactodots` (stow-based). Five hosts are configured: `mactone` (physical desktop), `mactopad` (physical laptop), `vm` (QEMU test host), `mactoncino` (headless media server: jellyfin + navidrome), and `NTB0000001` (work laptop, standalone Home Manager on WSL).

## 1. Build / Deploy / Check Commands

- **Validate flake structure (fast):**
  ```bash
  nix flake show
  ```
- **Deploy locally (on NixOS):**
  ```bash
  nh os switch
  ```
  `nh` reads `NH_OS_FLAKE` (set in `modules/system/nh.nix`) so no `--flake` flag is needed. `nh os switch` auto-detects the current hostname and builds the matching `nixosConfiguration` (each host lives in `hosts/<name>/default.nix`). For a different target use `nh os switch -- --hostname <host>`.
- **Deploy remotely (`mactoncino`, via deploy-rs):**
  ```bash
  nix run nixpkgs#deploy-rs -- .#mactoncino
  ```
  Node config lives in `modules/deploy.nix` (`flake.deploy`); magic + auto rollback enabled. Other hosts still use:
  ```bash
  nixos-rebuild -- switch \
    --flake .#<host> --impure --target-host xitonight@<host> --ask-sudo-password
  ```
- **Deploy standalone Home Manager (`NTB0000001` / WSL):**
  ```bash
  home-manager switch --flake .#NTB0000001
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

- **Inputs:** `nixpkgs` (unstable), `flake-parts`, `import-tree`, `home-manager` (follows nixpkgs), `minegrub-theme`, `minecraft-plymouth-theme`, `hyprland`, `firefox-addons`, `zen-browser`, `devenv`, `nix-index-database`. All pinned in `flake.lock`.
- **Structure follows the [Dendritic Pattern](https://github.com/mightyiam/dendritic): every Nix file is a `flake-parts` module.** `flake.nix` is a thin entry point; `import-tree` auto-imports every `.nix` file under `modules/`, so there are no manual `imports = [...]` lists to maintain. Each file sets one or more `flake.<class>s.<name>` outputs (`flake.nixosModules.*`, `flake.homeModules.*`, `flake.nixosConfigurations.*`).
- **Home Manager runs as a NixOS module** (`useGlobalPkgs = true`, `useUserPackages = true`) for all hosts except `NTB0000001`, which uses standalone Home Manager (WSL, no NixOS). System + home build atomically in one `nh os switch`.
- **Layout:**
  ```
  flake.nix                # inputs + flake-parts mkFlake + import-tree ./modules (+ explicit host imports)
  modules/parts.nix        # systems, home-manager flakeModule import, flake.const (username/flakeDir/...)
  modules/core.nix         # flake.nixosModules.core: base user/sudo/greetd + imports all system features
  modules/home-manager.nix # flake.nixosModules.home-manager: HM-as-NixOS-module + extraSpecialArgs
  modules/home.nix         # flake.homeModules.base (stateVersion/user) + flake.homeImports (the home feature list)
  modules/system/    # OS-layer NixOS modules (1password, audio, bluetooth, boot, cachix, containers, fonts,
                    #   locale, network, nh, nix, nvidia, openvpn, overlays, packages, polkit, power, shell,
                    #   tailscale, udev, virtualization, kanata/)
  modules/desktop/  # graphical session (hyprland/ merged, kitty, rofi/, swaync/, gtk, qt, matugen/, fsh/,
                    #   scripts/, vesktop, mpv, zathura, zen, xdg)
  modules/shell/    # terminal & CLI (zsh, oh-my-posh, starship, fzf, eza, zoxide, bat, pay-respects,
                    #   yazi, btop, tmux, ssh)
  modules/dev/      # development (git.nix merged, devenv, lazygit, opencode, secretspec, nvim/)
  # Every file is a flake-parts module setting flake.nixosModules.<x> and/or flake.homeModules.<x>.
  # Grouping is by DOMAIN, not by nixos/home class — a cross-cutting feature (hyprland, git) lives in ONE
  # file under the relevant domain and exports both classes.
  modules/<domain>/<name>/source/  # raw config trees for symlinked configs (nvim, rofi, matugen, hyprland)
  ```

### Wiring modules (`modules/*.nix`)

These are the only files that know how the features fit together. Feature files themselves are self-contained.

| File | Role |
|------|------|
| `parts.nix` | Imports `home-manager.flakeModules.home-manager` (declares the `flake.homeModules` option), sets `systems`, and `flake.const` (`username`, `flakeDir`, `papersDir`, `email`) |
| `base.nix` | `flake.nixosModules.base` — headless-safe foundation every NixOS host shares: user + SSH keys, sudo, shell, sops, boot, locale, network, nix/nh/cachix, overlays, git, ssh (agent option), tailscale, stateVersion |
| `core.nix` | `flake.nixosModules.core` — `base` + all desktop/hardware features (audio, bluetooth, fonts, greetd, hyprland, kanata, 1password, openvpn, packages, polkit, power, quickshare, steam, udev, containers, virtualization, nix-index) |
| `home-manager.nix` | `flake.nixosModules.home-manager` — HM NixOS module + `extraSpecialArgs` (incl. `monitorsConfig = config.mactoflake.hyprland.monitors`, `limitedColors = false`) |
| `home.nix` | `flake.homeModules.base` (home username/dir/stateVersion) + `flake.homeImports` (full desktop home feature list) + `flake.homeImportsServer` (CLI-only subset used by `mactoncino`) |

### NixOS-class modules

Each file sets `flake.nixosModules.<name>` and is auto-imported by import-tree. They live under `modules/system/` (plus cross-cutting `hyprland` in `modules/desktop/` and `git` in `modules/dev/`). `base.nix` provides the headless-safe foundation every NixOS host shares; `core.nix` pulls `base` plus all desktop/hardware features into desktop hosts. `nvidia.nix` and `media.nix` are opted into per-host. Toggleable behaviour lives behind `mactoflake.*` options set per-host.

| File | Purpose |
|------|---------|
| `1password.nix` | 1Password CLI + GUI integration; always installed (password manager, secretspec provider, Zen integration) regardless of `mactoflake.ssh.agent` |
| `bitwarden.nix` | Bitwarden desktop app; installed only when `mactoflake.ssh.agent = "bitwarden"` (its SSH agent works with Vaultwarden; desktop app must run, socket `~/.bitwarden-ssh-agent.sock`) |
| `boot.nix` | `mactoflake.boot.loader` option (`grub` \| `systemd-boot`); minegrub theme |
| `locale.nix` | TZ `Europe/Rome`, `en_US.UTF-8` + `it_IT.UTF-8` |
| `network.nix` | NetworkManager + OpenSSH |
| `nix.nix` | Flakes, auto-optimise, registry pin, weekly gc, allowUnfree |
| `nh.nix` | nh (nix helper) convenience wrapper |
| `overlays.nix` | Nixpkgs overlays |
| `packages.nix` | System-wide packages (CLI tools, desktop apps, theming) |
| `fonts.nix` | CaskaydiaCove Nerd Font, Poppins, Noto Emoji, Font Awesome + fontconfig |
| `hyprland.nix` → `modules/desktop/hyprland/` | **Merged feature:** `mactoflake.hyprland.monitors` option + `programs.hyprland` (withUWSM, xwayland, upstream); xdg portal; polkit; gnome-keyring — AND the home side (session vars, lua symlinks). See merged features below. |
| `git.nix` → `modules/dev/git.nix` | **Merged feature:** `mactoflake.git.signingKey` option (NixOS) + `programs.git`/`delta` (home, signs via 1Password SSH agent). |
| `audio.nix` | PipeWire full stack (alsa, pulse, jack, wireplumber) + rtkit |
| `bluetooth.nix` | `hardware.bluetooth` (bluez, fast-connect) + `bluetui` |
| `kanata.nix` | `mactoflake.input.kanata` option; uinput/input groups; ships `kanata.kbd` |
| `polkit.nix` | Polkit authentication agent |
| `tailscale.nix` | `mactoflake.network.tailscale` option + enableSSH |
| `cachix.nix` | Substituters (nix-community, hyprland) + trusted keys |
| `containers.nix` | `mactoflake.containers` option; Docker (rooted/rootless) + compose + dive + weekly prune |
| `media.nix` | Jellyfin + Navidrome; shared `media` group; tmpfiles-managed `/srv/media/{movies,tv,music}`; imported by `mactoncino` only |
| `arr.nix` | *arr stack: Sonarr (:8989) + Radarr (:7878) + Prowlarr (:9696) + qBittorrent (WebUI :8081, torrent :6881 — 8080 taken by Glance); all run with `media` group; downloads in `/srv/media/downloads` (same fs as library → hardlink imports); imported by `mactoncino` only |
| `slskd.nix` | slskd (Soulseek web client, WebUI :5030, listen :50300); runs with `media` group; downloads to `/srv/media/downloads/soulseek`, shares `/srv/media/music` back; credentials from sops secret file `secrets/slskd.yaml` rendered into an env template; imported by `mactoncino` only |
| `paperless.nix` | Paperless-ngx document management on :28981; OCR in `ita+eng`; admin password from sops secret `paperless-password` (`secrets/paperless.yaml`); imported by `mactoncino` only |
| `vaultwarden.nix` | Vaultwarden password manager on :8222 (Bitwarden-compatible, sqlite); `SIGNUPS_ALLOWED = false` (account exists — flip to `true` temporarily to add users, invites need SMTP); nightly 23:00 sqlite backup to `/var/backup/vaultwarden`; admin token from sops secret `admin-token` (`secrets/vaultwarden.yaml`) rendered into an env template; `DOMAIN = https://vault.mactonet.com`; imported by `mactoncino` only |
| `pihole.nix` | Pi-hole (native NixOS modules `pihole-ftl` + `pihole-web`): DNS ad blocking on :53, web UI on :3000; config is immutable (`misc.readOnly`) — all changes via Nix options, `pihole setpassword` won't persist |
| `home-assistant.nix` | Home Assistant on :8123; `pi_hole`/`met`/`default_config` components; more integrations must be added to `extraComponents` |
| `glance.nix` | Glance dashboard on :8080; declarative pages/widgets in `services.glance.settings`; imported by `mactoncino` only |
| `homepage.nix` | Homepage dashboard on :8082 (staging alongside Glance on :8080; will take over :8080 once Glance is removed); declarative `services.homepage-dashboard.{settings,widgets,services,bookmarks,customCSS}`; live API-key service integrations (Jellyfin, Navidrome, Sonarr/Radarr/Prowlarr, qBittorrent, slskd, Pi-hole v6, Home Assistant, Paperless-ngx, Vaultwarden) via sops template `homepage-env` → `environmentFiles` (`{{HOMEPAGE_VAR_*}}` substitution, values from `secrets/homepage.yaml` + reused `slskd.yaml`/`paperless.yaml` secrets); `siteMonitor` for services without widgets (n8n, Router); imported by `mactoncino` only |
| `n8n.nix` | n8n workflow automation on :5678; external task runners (Code node); encryption key + runners token from sops secret `n8n.yaml` (`secrets/n8n.yaml`); imported by `mactoncino` only |
| `printing.nix` | `mactoflake.printing` option; CUPS server (web UI on :631, LAN-wide listen + `allowFrom all`), Avahi/mDNS for printer discovery (`printer.local`); driverless printing (IPP Everywhere) by default — add `services.printing.drivers` per-printer if needed; imported by `mactoncino` only |
| `minecraft.nix` | `mactoflake.minecraft.servers` attrset (enable/slug/memory/version/port/whitelist/allowFlight/aikarFlags/autoStart) of modpack servers run as `itzg/minecraft-server:java21` docker containers (`AUTO_CURSEFORGE`, pack auto-installs at first start, `version` pins via `CF_FILENAME_MATCHER`, no CF API key needed — bundled in the image); state under `/srv/minecraft/<name>` (user/group `minecraft`, uid/gid 996); `--network=host` + `SERVER_PORT` so the centralized firewall governs access; ports must be unique across enabled servers (asserted); requires rooted docker (`mactoflake.containers` with `rootless = false`); imported by `mactoncino` only (atm10 on :25565 enabled, atm11 parked on :25566) |
| `caddy.nix` | `mactoflake.proxy` option (enable/domain/vhosts); Caddy reverse proxy with automatic Let's Encrypt HTTPS on :80/:443; vhosts map `.<domain>` subdomains to `127.0.0.1:<port>` upstreams (optional `prefix` rewrites subpath-serving backends like Navidrome/Paperless); ACME account email from `flake.const.email`; imported by `mactoncino` only |
| `nvidia.nix` | NVIDIA driver config (modesetting, open, GSP); imported by `mactone` only |

### Home-class modules

Each file sets `flake.homeModules.<name>` and is auto-imported by import-tree. They are spread across `modules/{desktop,shell,dev}/` by domain. `home.nix` aggregates them via `flake.homeImports`.

| File | Approach | Notes |
|------|----------|-------|
| `bat.nix` | `programs.bat` | Cat replacement with syntax highlighting |
| `btop.nix` | `programs.btop.settings` | Full 80+ setting attrset |
| `devenv.nix` | devenv integration | Dev environment manager |
| `eza.nix` | `programs.eza` | Modern ls replacement |
| `fzf.nix` | `programs.fzf` | Fuzzy finder |
| `git.nix` → `modules/dev/git.nix` | **Merged** `programs.git.settings` | Name + email; signs via `osConfig.mactoflake.git.signingKey` |
| `gtk.nix` | `gtk` HM module | adw-gtk3-dark, Papirus-Dark, Bibata cursor |
| `kitty.nix` | `programs.kitty.settings` + `keybindings` + `extraConfig` | `include colors.conf` for matugen runtime colors |
| `lazygit.nix` | `programs.lazygit` | Terminal UI for git |
| `matugen/` | matugen integration | Material You color generation |
| `mpv.nix` | `programs.mpv` | Media player config |
| `oh-my-posh.nix` | `programs.oh-my-posh` | Cross-shell prompt theme; `limitedColors` swaps extended color indices for named colors (WSL/Windows Terminal) |
| `opencode/` | `programs.opencode` | opencode (this tool) settings + tui keybinds |
| `pay-respects.nix` | pay-respects | `cd` replacement with smart suggestions |
| `prismlauncher.nix` | `programs.prismlauncher` | Minecraft launcher; jdks 17 + 21 bundled for instance selection (ATM10 needs 21) |
| `qt.nix` | Qt theming | Qt theme configuration |
| `rofi/` | rofi config | Application launcher |
| `scripts/` | Custom scripts | Single `flake.homeModules.scripts` with `brightness`, `rofi-clipboard`, `rofi-wallpaper`, `tgtheme` inlined |
| `secretspec/` | `xdg.configFile` | secretspec config (onepassword provider) |
| `ssh.nix` | **Merged** `mactoflake.ssh.agent` option (NixOS, imported by base) + SSH client config (home) | `mactoflake.ssh.agent` = `1password` \| `bitwarden` \| `rbw`: switches `SSH_AUTH_SOCK`/`IdentityAgent` (`~/.1password/agent.sock`, `~/.bitwarden-ssh-agent.sock`, `$XDG_RUNTIME_DIR/rbw/ssh-agent-socket`), git signing (op-ssh-sign vs stock ssh-keygen) and exports `MACTOFLAKE_SSH_AGENT` for the Hyprland autostart. rbw targets Vaultwarden with pinentry-qt prompts; keys are SSH-key vault items |
| `starship.nix` | `programs.starship` | Alt prompt (currently `enable = false`; oh-my-posh is active) |
| `swaync/` | swaync config | Notification daemon |
| `tmux.nix` | `programs.tmux` + `programs.sesh` + `programs.fzf.tmux` | Plugins via `pkgs.tmuxPlugins`; `limitedColors` swaps extended color indices for standard ones |
| `vesktop.nix` | vesktop config | Discord client |
| `xdg.nix` | `xdg.userDirs` | Custom dirs (dl/pics/docs/projects/videos) |
| `yazi.nix` | `programs.yazi` | Terminal file manager |
| `zathura.nix` | `programs.zathura` | PDF viewer |
| `zen.nix` | `programs.zen-browser` (from flake input) | Full profile, addons, bookmarks, workspaces |
| `zoxide.nix` | `programs.zoxide` | Smart cd replacement |
| `zsh.nix` | `programs.zsh` | Shell config + plugins |
| `nvim/` | `mkOutOfStoreSymlink` | See symlink strategy below |
| `fsh/` | `xdg.configFile` (generated) | zsh fast-syntax-highlighting theme; `limitedColors` swaps extended color indices for standard ones |
| `hypr/` → `modules/desktop/hyprland/` | **Merged** `mkOutOfStoreSymlink` | See symlink strategy below |

### `specialArgs` / `extraSpecialArgs`

- The constants (`username`, `flakeDir`, `papersDir`, `email`) live in `flake.const` (`modules/parts.nix`). Each host's `nixosSystem` call forwards them: `specialArgs = { inherit inputs; inherit (self.const) username flakeDir papersDir email; };`.
- `extraSpecialArgs` (set in `modules/home-manager.nix`) re-forwards `inputs`, `flakeDir`, `papersDir`, `username`, `email` to home modules and adds `monitorsConfig = config.mactoflake.hyprland.monitors` and `limitedColors = false`. The standalone `NTB0000001` host sets `limitedColors = true` (WSL/Windows Terminal can't redefine terminal colors 16+).
- Any module can declare `{ inputs, flakeDir, username, monitorsConfig, ... }:` and access these. `self` is NOT passed into the NixOS eval (it's used only at the flake-parts level to compose `modules` lists and `home-manager.users`).
- **Never reference `self.homeModules.*` from inside a `flake.homeModules.*` definition** — it causes an infinite recursion (a module can't reference the submodule it's part of). Cross-module references live in the wiring files (`core.nix`, `home.nix`) or host modules, which are under different `flake.*` branches.

- **Host branching** is done with `lib.mkIf` against the hostname, not by guessing at runtime.

## 4. Config Strategy: Nix Modules vs Out-of-Store Symlinks

Two strategies are used, depending on the tool:

### Structured Nix modules (preferred when available)

Tools with a Home Manager module (`programs.<x>.enable` + `.settings`) are configured in Nix. This gives type-checking, merge semantics, and atomic rebuilds. Examples: `btop`, `kitty`, `git`, `tmux`, `gtk`, `zen-browser`.

### Out-of-store symlinks (for large or natively-maintained configs)

Bigger configs, or configs that are better maintained in their native language (Lua, Vimscript), are **not** translated to Nix. Instead they are kept as raw source files in the repo and symlinked into `~/.config/` via `config.lib.file.mkOutOfStoreSymlink`. This means:

- Edits to the source files take effect immediately (no rebuild needed).
- The files live in the git-tracked repo tree under `modules/<domain>/<name>/source/`.
- HM manages the symlink; the content is outside the Nix store.

Current symlinked configs:

| Config | Source dir | Symlink target | Why symlinked |
|--------|-----------|----------------|----------------|
| Neovim | `modules/dev/nvim/source/` | `~/.config/nvim` | NvChad + lazy.nvim manages 40+ plugins; Nix-managed plugins would be a massive rewrite with no benefit |
| Hyprland | `modules/desktop/hyprland/source/` | `~/.config/hypr/` (per-file) | Lua API (`hl.*`) is Hyprland's native config; no benefit to porting to Nix |

### Stateful runtime data (never in flake)

Wallpapers, matugen-generated color files (`colors.conf`), and `~/.local/share` are pure state and excluded from the flake entirely.

## 5. Code Style (Nix)

- **Every `.nix` file under `modules/` is a `flake-parts` module** (the Dendritic Pattern) and is auto-discovered by `import-tree`. Each sets one or more `flake.<class>s.<name>` outputs. A file that is NOT a flake-parts module (e.g. `hardware-configuration.nix`, helper data) must live outside `modules/` or be `_`-prefixed so import-tree skips it.
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
  - `mactoncino` — headless server (`nixosModules.base` + `containers` (rooted docker) + `media` + `arr` + `slskd` + `pihole` + `home-assistant` + `glance` + `homepage` + `n8n` + `minecraft`), systemd-boot with `boot.loader.timeout = 0` (no menu; hold Space to enter systemd-boot), tailscale; media under `/srv/media`, minecraft under `/srv/minecraft`. Ports: 53 DNS (Pi-hole), 80/443 Caddy (public: music.mactonet.com → Navidrome, paperless.mactonet.com → Paperless, jelly.mactonet.com → Jellyfin, vault.mactonet.com → Vaultwarden), 25565 Minecraft (ATM10, public — `atm10.mactonet.com` via the zone's wildcard record), 3000 Pi-hole UI, 4533 Navidrome, 5030 slskd WebUI, 50300 Soulseek listen, 5678 n8n, 631 CUPS web UI, 6881 qBittorrent torrent, 7878 Radarr, 8080 Glance, 8082 Homepage, 8081 qBittorrent WebUI, 8096 Jellyfin, 8123 Home Assistant, 8222 Vaultwarden, 8989 Sonarr, 9696 Prowlarr, 28981 Paperless. Firewall: only 80/443 (Caddy) and 25565 (Minecraft) face the WAN/LAN; admin + service ports are tailnet-only (`interfaces.tailscale0`), LAN (`eno1`) gets ssh/631/53 only — rules are centralized in `hosts/mactoncino/default.nix`; service modules must NOT open firewall ports themselves.
  - `NTB0000001` — work laptop, standalone Home Manager (WSL, no NixOS); `limitedColors = true`.
- All NixOS machines run Tailscale and are reachable via their hostname over the tailnet.
- **Timezone:** `Europe/Rome`; locale `en_US.UTF-8` with `it_IT.UTF-8` regional formatting.
- **Hyprland** uses Lua as its native config language (since v0.55). The `hl.*` calls are the official Lua API — no rewrite or wrapper package needed.
