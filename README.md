# Manual config
- Install displaylink drivers: `nix-prefetch-url --name displaylink-610.zip https://www.synaptics.com/sites/default/files/exe_files/2024-10/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.1-EXE.zip`


# Updating wifi networks
Update `wifi.age` with `xml_to_env.py` in the secrets folder, using `adb shell su -c "cat /data/misc/apexdata/com.android.wifi/WifiConfigStore.xml" > WifiConfigStore.xml`.

```
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel --option substituters "https://winapps.cachix.org/ https://tiebe.cachix.org?priority=10 https://nix-community.cachix.org?priority=20 https://cache.nixos.org?priority=30 https://cache.nixos.org/" --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g= tiebe.cachix.org-1:gIjdnOcIlX9TOKT6StlrNvhCAnQiy9vAoxMfzMhVg54= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" --option experimental-features "nix-command flakes"

nix-env --profile /nix/var/nix/profiles/system --set ./result
sudo ./result/bin/switch-to-configuration switch
rm ./result

```