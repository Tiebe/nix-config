let
  yubikey_5c = "age1yubikey1qgjdwvurkzt96kq0ru2wwvpemcpemc2xdldxaas4fv6kf5w5s820ql6mvra";
  yubikey_5 = "age1yubikey1qtz92pnpac4tgeehratk52syxylpwftlujl8ey5curz4h62mam4kyw5jlsd";

  jupiter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgt8r0Bw2Zikcjz4NPvty826oHnznFyBtJFK1ngNVXS";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEvOgR7VedJwRvKO9wD8am7K388emFAgMk31NMzn2di";
  mercury = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOy/tfffA9oA8uP2WSBonNHsaOjwGmQApGUmlYY7M2rg";

  tiebe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCxANoXEguBulOVdL1jCNJYQs/SVUEE1Iq2rokl21lq";

  yubikeys = [yubikey_5c yubikey_5];
  hosts = [jupiter pluto mercury];

  all = yubikeys ++ hosts ++ [tiebe];
in {
  "password.age".publicKeys = all;
  "tailscale.age".publicKeys = all;
  "wifi.age".publicKeys = all;
  "atuin.age".publicKeys = all;
  "email/tiebe.tiebe.me.age".publicKeys = all;
  "email/tiebe.tiebe.dev.age".publicKeys = all;
  "email/tiebe.groosman.gmail.com.age".publicKeys = all;

  "avb/password.age".publicKeys = all;
  "avb/ota.key.base64.age".publicKeys = all;
  "avb/avb.key.base64.age".publicKeys = all;
  "avb/ota.cert.base64.age".publicKeys = all;

  "gpg/public.age".publicKeys = all;
  "gpg/private.age".publicKeys = all;
  "github_pk.age".publicKeys = all;
}
