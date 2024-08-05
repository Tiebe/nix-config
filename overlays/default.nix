# This file defines overlays
{inputs, ...}: {
  modifications = final: prev: {
    ragenix = prev.ragenix.override {
      plugins = [final.age-plugin-yubikey];
    };
  };
}
