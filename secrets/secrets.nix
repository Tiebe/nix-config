let
  yubikey_5c = "age1yubikey1qgjdwvurkzt96kq0ru2wwvpemcpemc2xdldxaas4fv6kf5w5s820ql6mvra";
  yubikey_5 = "age1yubikey1qtz92pnpac4tgeehratk52syxylpwftlujl8ey5curz4h62mam4kyw5jlsd";

  jupiter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgt8r0Bw2Zikcjz4NPvty826oHnznFyBtJFK1ngNVXS";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEvOgR7VedJwRvKO9wD8am7K388emFAgMk31NMzn2di";

  yubikeys = [yubikey_5c yubikey_5];
in {
  "password.age".publicKeys = [yubikey_5c jupiter pluto];
  "tailscale.age".publicKeys = [yubikey_5c jupiter pluto];
  "wifi.age".publicKeys = [yubikey_5c jupiter pluto];
  "atuin.age".publicKeys = [yubikey_5c jupiter pluto];
}
