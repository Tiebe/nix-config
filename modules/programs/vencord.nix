{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [ pkgs.vencord ];
}