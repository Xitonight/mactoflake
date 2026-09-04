{
  flake.nixosModules.minecraft =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.mactoflake.minecraft.servers;
      enabled = lib.filterAttrs (_: server: server.enable) cfg;
      enabledPorts = map (server: server.port) (lib.attrValues enabled);
    in
    {
      options.mactoflake.minecraft.servers = lib.mkOption {
        description = "Minecraft modpack servers run as itzg/minecraft-server containers.";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "this server";

              slug = lib.mkOption {
                type = lib.types.str;
                description = "CurseForge modpack slug (e.g. \"all-the-mods-10\").";
              };

              memory = lib.mkOption {
                type = lib.types.strMatching "[0-9]+[MG]";
                default = "12G";
                description = "RAM allocated to the server JVM (e.g. \"8G\", \"8192M\").";
              };

              version = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "CurseForge filename matcher pinning the pack version (e.g. \"3.3\"). null tracks the latest release.";
              };

              port = lib.mkOption {
                type = lib.types.port;
                default = 25565;
                description = "Server port (SERVER_PORT). Must be unique across enabled servers.";
              };

              whitelist = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Whitelisted players (usernames or UUIDs). Empty leaves the whitelist unmanaged.";
              };

              allowFlight = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Allow flight (modded flight items need this; vanilla anti-cheat otherwise kicks players).";
              };

              aikarFlags = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Use Aikar's G1GC JVM flags (recommended for modded servers).";
              };

              autoStart = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Start this server on boot and on deploy. Disable to start it manually via systemctl.";
              };

              viewDistance = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.positive;
                default = null;
                description = "View distance in chunks. null leaves the pack's default.";
              };

              simulationDistance = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.positive;
                default = null;
                description = "Simulation distance in chunks. null leaves the pack's default.";
              };

              difficulty = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "peaceful"
                    "easy"
                    "normal"
                    "hard"
                  ]
                );
                default = null;
                description = "Server difficulty. null leaves the pack's default.";
              };

              motd = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Message of the day (supports § color codes and \\n).";
              };

              jvmXXOpts = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Extra -XX JVM options, appended after Aikar's flags (a repeated flag overrides just that Aikar entry).";
              };
            };
          }
        );
      };

      config = lib.mkMerge [
        {
          warnings =
            let
              gcSelector =
                server:
                builtins.any (
                  opt: builtins.match ".*Use(G1GC|ZGC|Shenandoah|Z|ParallelGC|SerialGC).*" opt != null
                ) server.jvmXXOpts;
              conflicting = lib.filterAttrs (
                _: server: server.enable && server.aikarFlags && gcSelector server
              ) cfg;
            in
            lib.mapAttrsToList (
              name: _:
              "mactoflake.minecraft.servers.${name}: jvmXXOpts selects a garbage collector while aikarFlags is enabled — the -XX flag wins and Aikar's G1 tuning becomes inert. Set aikarFlags = false or drop the GC flag."
            ) conflicting;

          assertions = [
            {
              assertion = enabled == { } || config.virtualisation.docker.enable;
              message = "mactoflake.minecraft.servers requires the docker daemon (enable mactoflake.containers with rootless = false).";
            }
            {
              assertion = lib.length enabledPorts == lib.length (lib.unique enabledPorts);
              message = "mactoflake.minecraft.servers: enabled servers must not share the same port.";
            }
          ];
        }

        (lib.mkIf (enabled != { }) {
          virtualisation.oci-containers.backend = "docker";

          users.groups.minecraft.gid = 996;
          users.users.minecraft = {
            isSystemUser = true;
            group = "minecraft";
            uid = 996;
          };

          systemd.tmpfiles.rules = map (name: "d /srv/minecraft/${name} 0755 minecraft minecraft -") (
            lib.attrNames enabled
          );

          virtualisation.oci-containers.containers = lib.mapAttrs (name: server: {
            image = "itzg/minecraft-server:java21";
            inherit (server) autoStart;

            environment = {
              EULA = "TRUE";
              TZ = "Europe/Rome";
              MEMORY = server.memory;
              USE_AIKAR_FLAGS = if server.aikarFlags then "true" else "false";
              MODPACK_PLATFORM = "AUTO_CURSEFORGE";
              CF_SLUG = server.slug;
              SERVER_PORT = toString server.port;
              UID = toString config.users.users.minecraft.uid;
              GID = toString config.users.groups.minecraft.gid;
            }
            // lib.optionalAttrs (server.version != null) { CF_FILENAME_MATCHER = server.version; }
            // lib.optionalAttrs (server.whitelist != [ ]) {
              WHITELIST = lib.concatStringsSep "," server.whitelist;
            }
            // lib.optionalAttrs server.allowFlight { ALLOW_FLIGHT = "true"; }
            // lib.optionalAttrs (server.viewDistance != null) { VIEW_DISTANCE = toString server.viewDistance; }
            // lib.optionalAttrs (server.simulationDistance != null) {
              SIMULATION_DISTANCE = toString server.simulationDistance;
            }
            // lib.optionalAttrs (server.difficulty != null) { DIFFICULTY = server.difficulty; }
            // lib.optionalAttrs (server.motd != null) { MOTD = server.motd; }
            // lib.optionalAttrs (server.jvmXXOpts != [ ]) {
              JVM_XX_OPTS = lib.concatStringsSep " " server.jvmXXOpts;
            };

            volumes = [ "/srv/minecraft/${name}:/data" ];

            extraOptions = [
              "--network=host"
              "--stop-timeout=120"
            ];
          }) enabled;
        })
      ];
    };
}
