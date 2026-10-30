# Packages REA verifies at exact upstream versions that nixpkgs does not carry.
# Keep every pin aligned with REA's admission checks; see
# https://github.com/morluto/rea/tree/main/src (WabtRelease.ts,
# PwntoolsRelease.ts, JadxRelease.ts, javascript-recovery.md).
{pkgs}: let
  inherit (pkgs) lib;

  # Python bindings derive their version and source from the C library.
  unicorn = pkgs.unicorn.overrideAttrs (_old: {
    version = "2.1.2";
    src = pkgs.fetchFromGitHub {
      owner = "unicorn-engine";
      repo = "unicorn";
      tag = "2.1.2";
      hash = "sha256-qA84xBztyWmt/rUExhhZMkQzvDPx0UE9MAIPG/Su3iE=";
    };
  });

  # REA's pwntools bridge requires exactly pwntools 4.15.0, pyelftools 0.33
  # and unicorn 2.1.2; it rejects any other version.
  python = pkgs.python3.override {
    packageOverrides = _final: prev: {
      pyelftools = prev.pyelftools.overrideAttrs (_old: {
        version = "0.33";
        src = pkgs.fetchFromGitHub {
          owner = "eliben";
          repo = "pyelftools";
          tag = "v0.33";
          hash = "sha256-NqF5A6PRl4uncwNS9j44fIV7ovlljiucvV2Msv0LK/w=";
        };
      });
      # 2.1.2's binding asks versioningit for a dynamic version, which needs
      # VCS metadata that fetchFromGitHub strips; pin the version instead.
      unicorn =
        (prev.unicorn.override {
          unicorn = unicorn;
        })
        .overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace pyproject.toml \
                --replace-fail 'dynamic = ["version"]' 'version = "2.1.2"' \
                --replace-fail 'requires = ["setuptools", "build", "wheel", "versioningit"]' 'requires = ["setuptools", "build", "wheel"]' \
                --replace-fail '[tool.versioningit]' '# version pinned in derivation'
            '';
        });
    };
  };
in {
  wabt = pkgs.wabt.overrideAttrs (_old: {
    version = "1.0.42";
    src = pkgs.fetchFromGitHub {
      owner = "WebAssembly";
      repo = "wabt";
      tag = "1.0.42";
      hash = "sha256-33XpYt42Jw2xfwBR64jVI3VYVIKD1YjND9SSI6CdkaM=";
      fetchSubmodules = true;
    };
  });

  wakaru = pkgs.stdenv.mkDerivation {
    pname = "wakaru";
    version = "1.14.0";

    src = pkgs.fetchurl {
      url = "https://github.com/pionxzh/wakaru/releases/download/v1.14.0/wakaru-linux-x64.tar.gz";
      hash = "sha256-2w5iADRyMZWrQm6U0A1V29j9AQapKK2iVj8RAxltCfo=";
    };

    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [pkgs.stdenv.cc.cc.lib];

    sourceRoot = ".";
    dontStrip = true;

    installPhase = ''
      install -Dm755 wakaru $out/bin/wakaru
    '';

    meta = {
      description = "JavaScript decompiler and source recovery engine used by REA";
      homepage = "https://github.com/pionxzh/wakaru";
      license = lib.licenses.asl20;
      mainProgram = "wakaru";
      platforms = ["x86_64-linux"];
    };
  };

  jadx-headless-mcp = pkgs.stdenvNoCC.mkDerivation {
    pname = "jadx-headless-mcp";
    version = "0.7.1";

    src = pkgs.fetchurl {
      url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar";
      hash = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm644 $src $out/share/java/jadx-headless-mcp-0.7.1-all.jar
    '';

    meta = {
      description = "Headless JADX MCP bridge consumed by REA's Android provider";
      homepage = "https://github.com/1013503897/jadx-headless-mcp";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  };

  pwntools-python = python.withPackages (ps: [ps.pwntools]);
}
