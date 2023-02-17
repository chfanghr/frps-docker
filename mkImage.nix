{
  frpsConfig,
  frp,
  dockerTools,
  writeTextFile,
  buildEnv,
  lib,
  ...
}: let
  configFile = writeTextFile {
    name = "frpsConfig";
    text = lib.generators.toINI {} frpsConfig;
    checkPhase = "${frp}/bin/frps verify -c $out";
  };

  exposedPorts =
    builtins.listToAttrs
    (
      builtins.map (key: {
        name = key;
        value = {};
      })
      (builtins.concatMap
        (port: [port "${port}/udp"])
        (lib.strings.splitString "," frpsConfig.common.allow_ports))
    )
    // {
      "${builtins.toString frpsConfig.common.bind_port}" = {};
      "${builtins.toString frpsConfig.common.bind_udp_port}/udp" = {};
    };
in
  dockerTools.buildLayeredImage {
    name = "frps";
    created = "now";
    config = {
      ExposedPorts = exposedPorts;
      Cmd = ["${frp}/bin/frps" "-c" configFile];
    };
  }
