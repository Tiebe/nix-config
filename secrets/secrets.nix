let
  yubikey_5c = "age1yubikey1qgjdwvurkzt96kq0ru2wwvpemcpemc2xdldxaas4fv6kf5w5s820ql6mvra";
in {
  "password.age".publicKeys = [ yubikey_5c ];
}