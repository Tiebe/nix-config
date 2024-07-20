{config, ...}: {
  imports = [
    ./config.nix
  ];

  #xdg.configFile."kwinoutputconfig.json".source = config.lib.file.mkOutOfStoreSymlink ./kwinoutputconfig.json;
}
