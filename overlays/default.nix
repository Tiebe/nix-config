# This file defines overlays
{inputs, ...}: {
  modifications = final: prev: {
    ragenix = prev.ragenix.override {
      plugins = [final.age-plugin-yubikey];
    };

    vencord = prev.vencord.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = builtins.trace "test" "Tiebe";
        repo = "Vencord";
        rev = "v${prev.version}";
        hash = "";
      };
    });
  };
}
