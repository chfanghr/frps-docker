{
  frpsConfig,
  frp,
  dockerTools,
  writeTextFile,
  buildEnv,
  lib,
  ...
}: let
  inherit (builtins) toString map concatMap listToAttrs;
  inherit (lib.strings) splitString;
  inherit (lib.attrsets) hasAttrByPath;

  configFile = writeTextFile {
    name = "frpsConfig";
    text = lib.generators.toINI {} frpsConfig;
    checkPhase = "${frp}/bin/frps verify -c $out";
  };

  udpPort =
    if hasAttrByPath ["common" "bind_udp_port"] frpsConfig
    then frpsConfig.common.bind_udp_port
    else frpsConfig.common.bind_port;

  exposedPorts =
    listToAttrs
    (
      map (key: {
        name = key;
        value = {};
      })
      (concatMap
        (port: [port "${port}/udp"])
        (splitString "," frpsConfig.common.allow_ports))
    )
    // {
      "${toString frpsConfig.common.bind_port}" = {};
      "${toString udpPort}/udp" = {};
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
