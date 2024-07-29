{
  config,
  pkgs,
  ...
}: {
  programs.spotify-player = {
    enable = true;
    settings = {
      client_id = "08d3521c86bc4703b45d48c5006803d7";
      enable_streaming = "Never";
    };  
  };
}
