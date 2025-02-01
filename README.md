# Manual config
- Install displaylink drivers: `nix-prefetch-url --name displaylink-600.zip https://www.synaptics.com/sites/default/files/exe_files/2024-05/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.0-EXE.zip`


# Updating wifi networks
Update `wifi.age` with `xml_to_env.py` in the secrets folder, using `adb shell su -c "cat /data/misc/apexdata/com.android.wifi/WifiConfigStore.xml" > WifiConfigStore.xml`.