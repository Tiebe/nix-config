let
  yubikey_5c = "age1yubikey1qgjdwvurkzt96kq0ru2wwvpemcpemc2xdldxaas4fv6kf5w5s820ql6mvra";
  yubikey_5 = "age1yubikey1qtz92pnpac4tgeehratk52syxylpwftlujl8ey5curz4h62mam4kyw5jlsd";

  yubikeys = [yubikey_5c yubikey_5];
in {
  "password.age".publicKeys = [yubikey_5c];
  "tailscale.age".publicKeys = [yubikey_5c];
  "wifi.age".publicKeys = [yubikey_5c];
  "atuin.age".publicKeys = [yubikey_5c];
}
