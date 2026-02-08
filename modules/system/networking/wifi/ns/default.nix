{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.networking.wifi;
in
{
  config = mkIf cfg.enable {
    systemd.services.nstrein-login = {
      description = "NS Trein captive portal login";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "custom-home-manager-upgrade-execstart.sh" ''
set -euo pipefail

# ---- get local IP (similar logic to the Python socket trick) ----
get_ip() {
  ip route get 10.254.254.254 2>/dev/null \
    | ${pkgs.gawk}/bin/awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}' \
    || echo "127.0.0.1"
}

IP=$(get_ip)

# ---- headers ----
UA="Mozilla/5.0 (X11; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0"

# cookie jar to keep the session
COOKIE_JAR=$(mktemp)

# ---- GET page to extract CSRF token ----
HTML=$(${pkgs.curl}/bin/curl -s \
  -c "$COOKIE_JAR" \
  -H "User-Agent: $UA" \
  -H "Accept: */*" \
  -H "Accept-Language: en-US,en;q=0.9" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Origin: http://portal.nstrein.ns.nl" \
  -H "Connection: keep-alive" \
  -H "DNT: 1" \
  -H "Sec-GPC: 1" \
  -H "Priority: u=0" \
  http://portal.nstrein.ns.nl/)

# ---- extract csrfToken ----
CSRF_TOKEN=$(echo "$HTML" \
  | grep -oP 'id="csrfToken"\s+value="\K[^"]+')

if [[ -z "''${CSRF_TOKEN:-}" ]]; then
  echo "No csrf token found."
  exit 0
fi

echo "CSRF Token found: $CSRF_TOKEN"

# ---- POST request ----
STATUS=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" \
  -b "$COOKIE_JAR" \
  -H "User-Agent: $UA" \
  -H "Accept: */*" \
  -H "Accept-Language: en-US,en;q=0.9" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Origin: http://portal.nstrein.ns.nl" \
  -H "Connection: keep-alive" \
  -H "DNT: 1" \
  -H "Sec-GPC: 1" \
  -H "Priority: u=0" \
  --max-time 15 \
  -X POST \
  "http://portal.nstrein.ns.nl/nstrein:main/internet?csrfToken=''${CSRF_TOKEN}&ip=''${IP}")

echo "$STATUS"

# cleanup
rm -f "$COOKIE_JAR"
          ''}";
      };
    };

    networking.networkmanager.dispatcherScripts = [
      {
        source = pkgs.writeShellScript "nstrein-dispatcher" ''
          if [ "$2" = "up" ] && [ "$CONNECTION_ID" = "Wifi in de trein"* ]; then
            systemctl start nstrein-login.service
          fi
        '';
      }
    ];
  };
}