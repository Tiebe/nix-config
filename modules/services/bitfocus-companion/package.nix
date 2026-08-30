{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchurl,
  nodejs_26,
  git,
  python3,
  udev,
  yarn-berry_4,
  libusb1,
  dart-sass,
  electron,
  makeWrapper,
  nix-update-script,
}: let
  # nixpkgs only has yarn 4.14.1, whose builtin `compat/typescript` patch has an unbounded
  # `semver exclusivity >=5.7.1-rc` hunk set, so it is also applied to the TypeScript 6 package
  # companion 5.x depends on (typescript@npm:@typescript/typescript6@6.0.2). That package has no
  # `lib/_tsc.js`; a missing file raises ENOENT rather than UnmatchedHunkError, which yarn does
  # not swallow for `optional!` patches, so the install aborts. Upstream pins yarn 4.17.1, which
  # knows about TypeScript 6. Drop the patch instead - it only teaches tsc about PnP resolution,
  # which is irrelevant here because companion uses `nodeLinker: node-modules`.
  yarn-berry = yarn-berry_4.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        grep -q getTypescriptPatch packages/plugin-compat/sources/index.ts
        sed -i '/getTypescriptPatch/d' packages/plugin-compat/sources/index.ts
      '';
  });

  # companion 5.x requires node >=26.5.0 <27 (see package.json engines / .node-version)
  nodejs = nodejs_26;

  # assets/builtin-surface-modules.json, fetched at build time by tools/fetch_builtin_modules.mts.
  # hashes are the `tarSha` values from that manifest, converted to SRI.
  builtinSurfaces = {
    elgato-stream-deck = fetchurl {
      url = "https://s4.bitfocus.io/developer-module-builds/surface/elgato-stream-deck/v1.4.6-c7ea9961c73fc6bf184b563d03c64b5607312d8d/elgato-stream-deck-v1.4.6.tgz";
      hash = "sha256-0zYgn2ao2yhy3CSlHbdqfV9YWWwUiQ5kibDjT4uqOn8=";
    };
    xkeys = fetchurl {
      url = "https://s4.bitfocus.io/developer-module-builds/surface/xkeys/v1.0.2-876f00ee194faa57ec14468b7019bbaa516a9e6d/xkeys-v1.0.2.tgz";
      hash = "sha256-LYJD0Wb90hIIs8AIiZoqLxxKtMWko9rryPSds9ZYCac=";
    };
  };

  selectSystem = attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  platform = selectSystem {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    armv7l-linux = "linux-armv7l";
  };
in
  stdenv.mkDerivation rec {
    pname = "bitfocus-companion";
    version = "5.0.4";

    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "bitfocus";
      repo = "companion";
      tag = "v${version}";
      hash = "sha256-ghnpbFSwxLfpYY20wjKsM9hJsZIa/SmgTQPZ+xsPQh8=";
    };

    passthru.updateScript = nix-update-script {};

    postPatch = ''
      # patch out git calls to generate version strings.
      substituteInPlace tools/lib.mts --replace-fail "return await fcn()" "return \"v${version}\" as unknown as T"

      # drop yarn config options unknown to yarn ${yarn-berry.version} (npmMinimalAgeGate, npmPreapprovedPackages).
      # approvedGitRepositories is required by yarn >= 4.14 for the one git dependency in the lockfile,
      # compressionLevel: 0 matches the `10c0` cacheKey the lockfile checksums were generated with.
      printf "nodeLinker: node-modules\nenableScripts: false\ncompressionLevel: 0\napprovedGitRepositories:\n  - '**'\n" > .yarnrc.yml

      # remove the yarn install during the build, since there is no internet connection, and everything has already been installed by yarnBerryConfigHook
      substituteInPlace tools/build/package.mts --replace-fail "await $\`yarn install --no-immutable\`" ""

      # remove node download, since we'll use the nix version
      substituteInPlace tools/build/package.mts \
        --replace-fail "const nodeVersions = await fetchNodejs(platformInfo)" "const nodeVersions: [string, string][] = []" \
        --replace-fail "await fs.createSymlink(latestRuntimeDir, path.join(runtimesDir, 'main'), 'dir')" ""

      substituteInPlace companion/lib/Instance/NodePath.ts \
        --replace-fail "if (!(await fs.pathExists(nodePath))) return null" "return '${lib.getExe nodejs}'"

      # forward LD_LIBRARY_PATH to module child processes, so surface modules can find libusb/libudev
      substituteInPlace companion/lib/Instance/Environment.ts \
        --replace-fail "'DISABLE_IPV6'," "'DISABLE_IPV6', 'LD_LIBRARY_PATH',"
    '';

    nativeBuildInputs = [
      nodejs
      yarn-berry.yarnBerryConfigHook
      git
      python3
      yarn-berry
      makeWrapper
    ];

    buildInputs = [
      libusb1
      dart-sass
      nodejs
      electron
      udev
    ];

    missingHashes = ./missing-hashes.json;

    offlineCache = yarn-berry.fetchYarnBerryDeps {
      inherit src missingHashes;
      hash = "sha256-K+hOgkTp764O1DQJ6wwO0TALE6Ff65PJf3KrHM22TGU=";
    };

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
      SKIP_LAUNCH_CHECK = true;
      ELECTRON = 0;
    };

    # with dontConfigure it doesn't seem to retrieve node_modules, so empty configurePhase instead
    configurePhase = ''
      runHook preConfigure
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      # force sass-embedded to use our own sass instead of the bundled one
      substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
          --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'

      # pre-populate builtin surface module cache to avoid network access during build
      mkdir -p .cache/builtin-surfaces/elgato-stream-deck
      tar -xzf ${builtinSurfaces.elgato-stream-deck} --strip-components=1 -C .cache/builtin-surfaces/elgato-stream-deck
      mkdir -p .cache/builtin-surfaces/xkeys
      tar -xzf ${builtinSurfaces.xkeys} --strip-components=1 -C .cache/builtin-surfaces/xkeys
      sha256sum assets/builtin-surface-modules.json | awk '{print $1}' > .cache/builtin-surfaces-checksum.txt

      yarn dist ${platform}

      runHook postBuild
    '';

    preInstall = ''
      # remove node runtime, since we will always use the nix node runtime
      rm -rf .cache/node-runtimes
      rm -rf dist/node-runtimes
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/bitfocus-companion
      cp -r * $out/share/bitfocus-companion/

      makeWrapper ${lib.getExe nodejs} $out/bin/bitfocus-companion \
        --add-flags $out/share/bitfocus-companion/dist/main.js \
        --set LD_LIBRARY_PATH "${lib.makeLibraryPath [libusb1 udev]}" \
        --set NODE_PATH $out/share/bitfocus-companion/node_modules

      runHook postInstall
    '';

    meta = {
      description = "Program for controlling Stream Deck devices";
      longDescription = "Bitfocus Companion enables the Elgato Stream Deck and other controllers to be a professional shotbox surface for an increasing amount of different presentation switchers, video playback software and broadcast equipment.";
      homepage = "https://bitfocus.io/companion";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [tiebe];
      mainProgram = "bitfocus-companion";
      platforms = lib.platforms.linux;
    };
  }
