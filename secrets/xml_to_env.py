#!/usr/bin/env python3
"""
This script converts an Android WifiConfigStore.xml file
to an environment file suitable for agenix. It now supports:
  - PSK networks (PreSharedKey)
  - Enterprise networks (using Identity and Password)
  - Hidden networks (hiddenSSID)
  - Extraction of key management type from the ConfigKey field,
    converting it to one of the allowed values:
    "none", "ieee8021x", "wpa-none", "wpa-psk", or "wpa-eap".

For each network it outputs:
  WIFI_SSID_<i>
  WIFI_PSK_<i>
  WIFI_USERNAME_<i>
  WIFI_PASSWORD_<i>
  WIFI_HIDDEN_<i>
  WIFI_KEY_MGMT_<i>
and a final count in WIFI_NETWORK_COUNT.
"""

import xml.etree.ElementTree as ET
import argparse
import sys

def extract_key_mgmt(text):
    """
    Given a ConfigKey field value, extract the key management type.
    
    For example, if text is:
       "wifi"WPA_PSK
    then return:
       WPA_PSK
    """
    if not text:
        return ""
    pos = text.rfind('"')
    if pos == -1:
        return ""
    return text[pos+1:]

def convert_key_mgmt(k):
    """
    Convert the extracted key management string (e.g. "WPA_PSK", "WPA_EAP")
    to one of the allowed NetworkManager values:
      - "wpa-psk" for WPA_PSK,
      - "wpa-eap" for WPA_EAP,
      - etc.
    If the value is not recognized, convert to lowercase and replace underscores with hyphens.
    """
    if not k:
        return ""
    mapping = {
        "WPA_PSK": "wpa-psk",
        "WPA_EAP": "wpa-eap",
        # You can add more explicit mappings here if needed.
    }
    return mapping.get(k, k.lower().replace("_", "-"))

def parse_wifi_config(xml_file):
    """
    Parse the given WifiConfigStore.xml and return a list of dictionaries,
    each with the following keys:
      - ssid: The Wi-Fi SSID.
      - psk: The pre-shared key (if available).
      - username: For enterprise networks, the identity.
      - password: For enterprise networks, the password.
      - hidden: "true" or "false" (as a string) indicating if the network is hidden.
      - key_mgmt: The key management type converted to the allowed format.
      
    Expected XML structure:
      <WifiConfigStoreData>
        <NetworkList>
          <Network>
            <WifiConfiguration>
              <string name="SSID">"MySSID"</string>
              <string name="PreSharedKey">"MyPassword"</string>
              <string name="Identity">"MyUser"</string>
              <string name="Password">"MyEnterprisePass"</string>
              <string name="ConfigKey">&quot;eduroam&quot;WPA_EAP</string>
              <boolean name="hiddenSSID" value="true" />
              ...
            </WifiConfiguration>
          </Network>
          ...
        </NetworkList>
      </WifiConfigStoreData>
    """
    try:
        tree = ET.parse(xml_file)
    except Exception as e:
        print(f"Error parsing XML: {e}", file=sys.stderr)
        sys.exit(1)

    root = tree.getroot()
    networks = []
    network_list = root.find("NetworkList")
    if network_list is None:
        print("No <NetworkList> element found in XML.", file=sys.stderr)
        return networks

    for network in network_list.findall("Network"):
        wifi_config = network.find("WifiConfiguration")
        if wifi_config is None:
            continue

        ssid = None
        psk = ""
        username = "no_eap"
        eap_password = "no_eap"
        hidden = "false"
        key_mgmt = ""  # Holds the raw key management string from ConfigKey

        for child in wifi_config:
            name = child.get("name")
            if child.tag == "string":
                text = child.text or ""
                # Remove surrounding quotes if present.
                if text.startswith('"') and text.endswith('"'):
                    text = text[1:-1]
                if name == "SSID":
                    ssid = text
                elif name == "PreSharedKey":
                    psk = text
                elif name == "Identity":
                    username = text
                    if username == "":
                        username == "no_eap"
                elif name == "Password":
                    eap_password = text
                    if eap_password == "":
                        eap_password == "no_eap"
                elif name == "hiddenSSID":
                    hidden = text.lower()
                elif name == "ConfigKey":
                    key_mgmt = extract_key_mgmt(text)
            elif child.tag == "boolean":
                if name == "hiddenSSID":
                    hidden = (child.get("value") or "false").lower()

        # Convert the raw key management to the allowed format.
        key_mgmt = convert_key_mgmt(key_mgmt)

        if ssid is not None:
            networks.append({
                "ssid": ssid,
                "psk": psk,
                "username": username,
                "password": eap_password,
                "hidden": hidden,
                "key_mgmt": key_mgmt,
            })
    return networks

def write_env_file(networks, output_file):
    """
    Write the environment file for agenix.
    
    For each network with index i, output:
      WIFI_SSID_i
      WIFI_PSK_i
      WIFI_USERNAME_i
      WIFI_PASSWORD_i
      WIFI_HIDDEN_i
      WIFI_KEY_MGMT_i
      
    And the final count:
      WIFI_NETWORK_COUNT=<number_of_networks>
    """
    try:
        with open(output_file, "w") as f:
            f.write(f"WIFI_NETWORK_COUNT={len(networks)}\n")
            for idx, net in enumerate(networks):
                f.write(f'WIFI_SSID_{idx}="{net["ssid"]}"\n')
                f.write(f'WIFI_PSK_{idx}="{net["psk"]}"\n')
                f.write(f'WIFI_USERNAME_{idx}="{net["username"]}"\n')
                f.write(f'WIFI_PASSWORD_{idx}="{net["password"]}"\n')
                f.write(f'WIFI_HIDDEN_{idx}="{net["hidden"]}"\n')
                f.write(f'WIFI_KEY_MGMT_{idx}="{net["key_mgmt"]}"\n')
    except Exception as e:
        print(f"Error writing env file: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Convert WifiConfigStore.xml to a secrets environment file for agenix."
    )
    parser.add_argument("xml_file", help="Path to WifiConfigStore.xml")
    parser.add_argument("output_file", help="Path to output environment file")
    args = parser.parse_args()

    networks = parse_wifi_config(args.xml_file)
    if not networks:
        print("No networks found in the XML file.", file=sys.stderr)
        sys.exit(1)
    write_env_file(networks, args.output_file)
    print(f"Successfully wrote {len(networks)} networks to {args.output_file}")

if __name__ == "__main__":
    main()
