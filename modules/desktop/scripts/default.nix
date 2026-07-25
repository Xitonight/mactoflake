{
  flake.homeModules.scripts =
    {
      pkgs,
      papersDir,
      ...
    }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "brightness" ''
          set -euo pipefail

          STEP=5
          CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/brightness"
          CACHE_FILE="$CACHE_DIR/state"
          MONITORS_FILE="$CACHE_DIR/monitors"
          mkdir -p "$CACHE_DIR"

          # ── monitor detection (cached for the session) ───────────────────────────
          detect_monitors() {
              ${pkgs.ddcutil}/bin/ddcutil detect --brief 2>/dev/null | awk '
                  /I2C bus:/ {
                      bus = $0; sub(/.*i2c-/, "", bus); gsub(/ /, "", bus)
                  }
                  /DRM connector:/ {
                      conn = $0; sub(/.*card[0-9]+-/, "", conn); gsub(/ /, "", conn)
                  }
                  /^$/ && bus != "" {
                      print bus " " conn
                      bus = ""; conn = ""
                  }
                  END { if (bus != "") print bus " " conn }
              '
          }

          get_monitors() {
              if [ ! -f "$MONITORS_FILE" ] || [ -z "$(cat "$MONITORS_FILE")" ]; then
                  detect_monitors > "$MONITORS_FILE"
              fi
              cat "$MONITORS_FILE"
          }

          # ── cache helpers ────────────────────────────────────────────────────────
          cache_get() {
              local bus="$1"
              if [ -f "$CACHE_FILE" ]; then
                  grep "^''${bus}=" "$CACHE_FILE" 2>/dev/null | tail -1 | cut -d= -f2
              fi
          }

          cache_set() {
              local bus="$1" value="$2"
              if [ -f "$CACHE_FILE" ]; then
                  sed -i "/^''${bus}=/d" "$CACHE_FILE" 2>/dev/null || true
              fi
              echo "''${bus}=''${value}" >> "$CACHE_FILE"
          }

          # ── DDC helpers (set only, no read) ─────────────────────────────────────
          set_brightness() {
              local bus="$1" value="$2"
              value=$(printf '%.0f' "$value")
              [ "$value" -lt 1 ] && value=1
              [ "$value" -gt 100 ] && value=100
              ${pkgs.ddcutil}/bin/ddcutil -b "$bus" setvcp 10 "$value" 2>/dev/null
              cache_set "$bus" "$value"
          }

          get_focused_bus() {
              local focused_name
              focused_name=$(${pkgs.hyprland}/bin/hyprctl monitors -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name' 2>/dev/null || true)
              if [ -n "$focused_name" ]; then
                  while IFS=' ' read -r bus connector; do
                      [ "$connector" = "$focused_name" ] && echo "$bus" && return
                  done < <(get_monitors)
              fi
              get_monitors | head -1 | cut -d' ' -f1
          }

          # ── init: read current values into cache ─────────────────────────────────
          cmd_init() {
              > "$CACHE_FILE"
              while IFS=' ' read -r bus connector; do
                  local raw
                  raw=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
                  cache_set "$bus" "''${raw:-50}"
                  echo "''${connector}: ''${raw:-50}%"
              done < <(get_monitors)
          }

          # ── commands ─────────────────────────────────────────────────────────────
          cmd_get() {
              while IFS=' ' read -r bus connector; do
                  local cached
                  cached=$(cache_get "$bus")
                  if [ -z "$cached" ]; then
                      cached=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
                      cache_set "$bus" "''${cached:-50}"
                  fi
                  echo "''${connector}: ''${cached}%"
              done < <(get_monitors)
          }

          cmd_set() {
              local value="$1"
              local target_bus="''${2:-}"
              while IFS=' ' read -r bus connector; do
                  if [ -z "$target_bus" ] || [ "$bus" = "$target_bus" ]; then
                      set_brightness "$bus" "$value"
                      echo "''${connector}: ''${value}%"
                  fi
              done < <(get_monitors)
          }

          cmd_up() {
              local delta="''${1:-$STEP}"
              while IFS=' ' read -r bus connector; do
                  local cached
                  cached=$(cache_get "$bus")
                  if [ -z "$cached" ]; then
                      cached=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
                  fi
                  local new=$(( cached + delta ))
                  set_brightness "$bus" "$new"
                  echo "''${connector}: ''${new}%"
              done < <(get_monitors)
          }

          cmd_down() {
              local delta="''${1:-$STEP}"
              while IFS=' ' read -r bus connector; do
                  local cached
                  cached=$(cache_get "$bus")
                  if [ -z "$cached" ]; then
                      cached=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
                  fi
                  local new=$(( cached - delta ))
                  set_brightness "$bus" "$new"
                  echo "''${connector}: ''${new}%"
              done < <(get_monitors)
          }

          cmd_focused_up() {
              local delta="''${1:-$STEP}"
              local bus
              bus=$(get_focused_bus)
              local cached
              cached=$(cache_get "$bus")
              if [ -z "$cached" ]; then
                  cached=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
              fi
              local new=$(( cached + delta ))
              set_brightness "$bus" "$new"
              echo "''${new}%"
          }

          cmd_focused_down() {
              local delta="''${1:-$STEP}"
              local bus
              bus=$(get_focused_bus)
              local cached
              cached=$(cache_get "$bus")
              if [ -z "$cached" ]; then
                  cached=$(${pkgs.ddcutil}/bin/ddcutil -b "$bus" getvcp 10 --brief 2>/dev/null | awk '{print $4}')
              fi
              local new=$(( cached - delta ))
              set_brightness "$bus" "$new"
              echo "''${new}%"
          }

          # ── main ─────────────────────────────────────────────────────────────────
          case "''${1:-help}" in
              init)         cmd_init ;;
              get)          cmd_get ;;
              set)          cmd_set "''${2:-50}" "''${3:-}" ;;
              up)           cmd_up "''${2:-$STEP}" ;;
              down)         cmd_down "''${2:-$STEP}" ;;
              focused-up)   cmd_focused_up "''${2:-$STEP}" ;;
              focused-down) cmd_focused_down "''${2:-$STEP}" ;;
              redetect)     rm -f "$MONITORS_FILE"; cmd_init ;;
              list)         get_monitors ;;
              help|--help|-h)
                  echo "Usage: brightness <command> [args]"
                  echo ""
                  echo "Commands:"
                  echo "  init             Read current brightness into cache (run once at startup)"
                  echo "  get              Show brightness (from cache, reads DDC only if uncached)"
                  echo "  set <value> [bus]    Set brightness (1-100) on all or specific bus"
                  echo "  up [step]        Increase all monitors by step (default: $STEP)"
                  echo "  down [step]      Decrease all monitors by step (default: $STEP)"
                  echo "  focused-up [step]   Increase focused monitor by step"
                  echo "  focused-down [step] Decrease focused monitor by step"
                  echo "  redetect         Re-detect monitors and re-read brightness"
                  echo "  list             List detected monitors (bus connector)"
                  ;;
              *)
                  echo "Unknown command: $1" >&2
                  exit 1
                  ;;
          esac
        '')
        (pkgs.writeShellScriptBin "rofi-clipboard" ''
          ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -p "󰅏 Clipboard" -config ~/.config/rofi/clipboard.rasi | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
        '')
        (pkgs.writeShellScriptBin "rofi-wallpaper" ''
          [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" ] && . "''${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"
          WALLPAPER_DIR="${papersDir}"

          selection=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -exec basename {} \; | sort | while read -r name; do
            printf '%s\x00icon\x1f%s\n' "$name" "$WALLPAPER_DIR/$name"
          done | ${pkgs.rofi}/bin/rofi -dmenu -p "  Wallpapers" -config ~/.config/rofi/wallpaper.rasi)

          [ -z "$selection" ] && exit

          ${pkgs.matugen}/bin/matugen image "$WALLPAPER_DIR/$selection" --source-color-index 0
        '')
        (pkgs.writeShellScriptBin "tgtheme" ''
          # tgtheme - package a telegram-desktop theme from a colors file and a background
          #
          # a .tdesktop-theme is just a zip archive containing a colors definition file
          # and (optionally) a background image named "background.jpg". this script takes
          # the colors file generated by matugen and bundles it together with the current
          # wallpaper into a complete theme.

          cachedir="''${XDG_CACHE_HOME:-$HOME/.cache}/telegram"
          colors_default="$cachedir/colors.tdesktop-theme"
          walfile="''${XDG_CACHE_HOME:-$HOME/.cache}/wal/wal"
          outname="wal.tdesktop-theme"
          resize="1920x1080"
          blur_radius="0x16"

          msg()  { [ "$quiet" -eq 1 ] || printf " \033[1;34m::\033[0m %s\n" "$@"; }
          error() { printf " \033[1;31m::\033[0m %s\n" "$@" >&2; exit 1; }

          usage() {
          	cat <<EOF
          Usage: tgtheme [-i image] [-c colors] [-o output] [-r WxH] [-Bs] [-q] [-h]

          Bundle a colors.tdesktop-theme file and a background image into a
          .tdesktop-theme archive that telegram-desktop can import.

          Options:
            -i image    background image path (default: read from $walfile)
            -c colors   colors file (default: $colors_default)
            -o output   output .tdesktop-theme path (default: $cachedir/$outname)
            -r WxH      resize the image (default: $resize; pass "original" to skip)
            -b radius   gaussian blur radius, e.g. "0x16" (implies blur; see -B)
            -B          blur the background using the default radius ($blur_radius)
            -s hex      solid color mode: ignore the image and use a flat #rrggbb swatch
            -q          quiet (suppress status messages)
            -h          show this help
          EOF
          }

          main() {
          	local image="" outfile="" solid="" do_blur=0
          	quiet=0

          	while getopts ":i:c:o:r:b:Bs:qh" opt; do
          		case "$opt" in
          		i) image="$OPTARG" ;;
          		c) colors_default="$OPTARG" ;;
          		o) outfile="$OPTARG" ;;
          		r) resize="$OPTARG" ;;
          		b) do_blur=1; blur_radius="$OPTARG" ;;
          		B) do_blur=1 ;;
          		s) solid="$OPTARG" ;;
          		q) quiet=1 ;;
          		h) usage; exit 0 ;;
          		:) error "'-$OPTARG' requires an argument" ;;
          		\?) error "invalid option: '-$OPTARG'" ;;
          		esac
          	done

          	[ ! -f "$colors_default" ] && error "colors file not found: $colors_default"

          	outfile="''${outfile:-$cachedir/$outname}"
          	mkdir -p "$(dirname "$outfile")" || error "cannot create output directory"

          	local tempdir
          	tempdir="$(mktemp -d)"
          	trap 'rm -rf "$tempdir"' EXIT INT TERM

          	cp -f "$colors_default" "$tempdir/colors.tdesktop-theme"

          	if [ -n "$solid" ]; then
          		printf '%s' "$solid" | grep -Eq '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$' \
          			|| error "not a valid color code: $solid"
          		msg "solid background: $solid"
          		${pkgs.imagemagick}/bin/magick convert -size 256x256 "xc:$solid" "$tempdir/background.jpg" 2>/dev/null
          	else
          		# resolve image: explicit arg, else the wal wallpaper-path file
          		if [ -z "$image" ] && [ -f "$walfile" ]; then
          			read -r image <"$walfile"
          		fi
          		[ -z "$image" ] && error "no background image (pass -i or populate $walfile)"
          		[ ! -f "$image" ] && error "image not found: $image"

          		case "$(${pkgs.file}/bin/file -b --mime-type "$image")" in
          		image/*) ;;
          		*) error "not an image: $image" ;;
          		esac
          		image="$(readlink -f "$image")"

          		local conv_args=()
          		[ "$resize" != "original" ] && conv_args+=(-resize "$resize")
          		[ "$do_blur" -eq 1 ] && conv_args+=(-blur "$blur_radius")
          		${pkgs.imagemagick}/bin/magick convert "''${conv_args[@]}" "$image" "$tempdir/background.jpg" 2>/dev/null \
          			|| error "image conversion failed"

          		msg "background: $(basename "$image")''${do_blur:+ (blurred)}"
          	fi

          	# syncing entries (zip -FS) into an existing archive is faster than
          	# recreating it; fall back to a clean archive if the sync fails.
          	if ${pkgs.zip}/bin/zip -j -FS "$outfile" "$tempdir"/* >/dev/null 2>&1; then
          		:
          	else
          		rm -f "$outfile"
          		${pkgs.zip}/bin/zip -jq "$outfile" "$tempdir"/* >/dev/null 2>&1 \
          			|| error "failed to create theme archive"
          	fi

          	msg "theme generated: $outfile"
          }

          main "$@"
        '')
      ];
    };
}
