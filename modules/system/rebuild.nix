{
  flake.nixosModules.rebuild =
    {
      pkgs,
      flakeDir,
      ...
    }:
    let
      rebuild = pkgs.writeShellScript "mactoflake-rebuild" ''
        set -euo pipefail

        # wrapper sudo (setuid) instead of any store-path sudo; NixOS store paths can't be setuid
        export PATH="/run/wrappers/bin:/run/current-system/sw/bin:''${PATH:-}"

        action="''${1:-switch}"
        log_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/mactoflake"
        log="$log_dir/rebuild.log"
        mkdir -p "$log_dir"

        notify() {
          ${pkgs.libnotify}/bin/notify-send "$@" || true
        }

        SECONDS=0
        : > "$log"
        notify -t 5000 "Rebuild started" "nh os $action"

        if ${pkgs.nh}/bin/nh os "$action" 2>&1 | tee "$log"; then
          notify -t 10000 "Rebuild succeeded" "nh os $action finished in ''${SECONDS}s"
        else
          code=$?
          notify -u critical -t 0 "Rebuild failed (exit $code)" "$(tail -n 20 "$log")"
          exit "$code"
        fi
      '';

      nos = pkgs.writeShellScriptBin "nos" ''
        set -euo pipefail

        log_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/mactoflake"
        log="$log_dir/rebuild.log"
        mkdir -p "$log_dir"

        usage() {
          cat <<EOF
        Usage: nos [command|action]

        Commands:
          (default), switch   run 'nh os switch' in the background and follow the
                              output (Ctrl-C detaches, rebuild keeps running)
          start [action]      start in the background, return immediately
          watch [action]      follow a running or last rebuild
          status              systemctl status of the rebuild units
          boot|test|dry|build run 'nh os <action>' and follow

        The rebuild runs as a transient mactoflake-rebuild-<action>.service user
        unit (systemd-run) and notifies on success/failure. Transient on purpose:
        switch-to-configuration starts/restarts user units it finds in the
        configuration, which deadlocks or kills an activation hosted in one.
        Full log: $log or journalctl --user -u 'mactoflake-rebuild-*'
        EOF
        }

        follow() {
          local unit="$1" i state pid
          for ((i = 0; i < 100; i++)); do
            if [ -s "$log" ]; then
              break
            fi
            state=$(systemctl --user is-active "$unit" 2>/dev/null || true)
            if [ "$state" = "failed" ] || [ "$state" = "inactive" ]; then
              break
            fi
            sleep 0.1
          done
          if [ -s "$log" ]; then
            pid=$(systemctl --user show -p MainPID --value "$unit" 2>/dev/null || echo 0)
            if [ -n "$pid" ] && [ "$pid" != "0" ]; then
              exec tail -f -n +1 --pid="$pid" "$log"
            fi
            echo "--- rebuild not running, last output: ---" >&2
            tail -n 30 "$log"
          else
            echo "rebuild produced no output, showing journal:" >&2
            journalctl --user -u "$unit" -n 30 --no-pager || true
          fi
        }

        start_rebuild() {
          local action="$1" unit state
          unit="mactoflake-rebuild-$action"
          state=$(systemctl --user is-active "$unit.service" 2>/dev/null || true)
          if [ "$state" = "activating" ] || [ "$state" = "active" ]; then
            return 1
          fi
          systemctl --user reset-failed "$unit.service" 2>/dev/null || true
          : > "$log"
          systemd-run --user --collect --quiet --service-type=oneshot \
            --unit="$unit" \
            --setenv=NH_OS_FLAKE="${flakeDir}" \
            --setenv=NH_HOME_FLAKE="${flakeDir}" \
            --setenv=NH_FLAKE="${flakeDir}" \
            "${rebuild}" "$action"
        }

        launch() {
          local action="$1"
          if ! start_rebuild "$action"; then
            echo "rebuild ($action) already running, attaching..." >&2
          fi
          follow "mactoflake-rebuild-$action.service"
        }

        action="''${1:-switch}"
        case "$action" in
          switch | boot | test | dry | build)
            launch "$action"
            ;;
          start)
            action="''${2:-switch}"
            if ! start_rebuild "$action"; then
              echo "rebuild ($action) already running"
              notify-send "Rebuild already running" "watch with: nos watch $action" || true
              exit 0
            fi
            echo "rebuild ($action) started - follow with 'nos watch $action', notification when done"
            ;;
          watch)
            follow "mactoflake-rebuild-''${2:-switch}.service"
            ;;
          status)
            systemctl --user status "mactoflake-rebuild-*" --no-pager || true
            ;;
          help | -h | --help)
            usage
            ;;
          *)
            echo "unknown command: $1" >&2
            usage
            exit 1
            ;;
        esac
      '';
    in
    {

      environment.systemPackages = [ nos ];
    };

  flake.homeModules.rebuild =
    {
      pkgs,
      ...
    }:
    {
      xdg.dataFile = {
        "vicinae/scripts/rebuild.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            # @vicinae.schemaVersion 1
            # @vicinae.title Rebuild NixOS
            # @vicinae.mode compact
            # @vicinae.icon 🔄
            # @vicinae.description Start a background NixOS rebuild (nh os) as a systemd user unit; notifies on completion
            # @vicinae.keywords ["nixos","nh","switch","deploy","rebuild"]
            # @vicinae.argument1 { "type": "text", "placeholder": "action: switch, boot, test, dry or build", "optional": true }
            exec nos start "''${1:-switch}"
          '';
        };
        "vicinae/scripts/rebuild-watch.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            # @vicinae.schemaVersion 1
            # @vicinae.title Rebuild Watch
            # @vicinae.mode fullOutput
            # @vicinae.icon 👀
            # @vicinae.description Follow the running or last rebuild output (Ctrl-C detached rebuilds keep running)
            # @vicinae.keywords ["nixos","nh","rebuild","log","follow","tail"]
            exec nos watch
          '';
        };
        "vicinae/scripts/rebuild-status.sh" = {
          executable = true;
          text = ''
            #!/bin/sh
            # @vicinae.schemaVersion 1
            # @vicinae.title Rebuild Status
            # @vicinae.mode fullOutput
            # @vicinae.icon 🩺
            # @vicinae.description systemctl status of the mactoflake rebuild units
            # @vicinae.keywords ["nixos","nh","rebuild","systemctl","status"]
            exec nos status
          '';
        };
      };
    };
}
