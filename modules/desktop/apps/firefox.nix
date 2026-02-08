{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.firefox;

  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  options = {
    tiebe.desktop.apps.firefox = {
      enable = mkEnableOption "Firefox";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

    programs = {
      firefox = {
        enable = true;
        #package = pkgs.librewolf;
        /*
        ---- POLICIES ----
        */
        # Check about:policies#documentation for options.
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"
          PasswordManagerEnabled = false;

          /*
          ---- EXTENSIONS ----
          */
          # Check about:support for extension/add-on ID strings.
          # Valid strings for installation_mode are "allowed", "blocked",
          # "force_installed" and "normal_installed".
          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };
            # Bitwarden:
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # StudyTools
            "studytools@qkeleq10.dev" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/studytools/latest.xpi";
              installation_mode = "force_installed";
            };
            # Enhanced GitHub
            "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhanced-github/latest.xpi";
              installation_mode = "force_installed";
            };
            # SponsorBlock
            "{sponsorBlocker@ajay.app}" = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/sponsorblock/latest.xpi";
              installation_mode = "force_installed";
            };

            "{firefox-extension@steamdb.info}" = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/steam-database/latest.xpi";
              installation_mode = "force_installed";
            };

            "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/violentmonkey/latest.xpi";
              installation_mode = "force_installed";
            };

            "search@kagi.com" = {
              "install_url" = "https://addons.mozilla.org/en-US/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
              installation_mode = "force_installed";
            };
          };

          /*
          ---- PREFERENCES ----
          */
          # Check about:config for options.
          Preferences = {
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
            "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            "browser.sessionstore.resume_from_crash" = lock-false;
          };

          "3rdparty" = {
            Extensions = {
              "{446900e4-71c2-419f-a6a7-df9c091e268b}".environment = {
                base = "https://bitwarden.groosman.nl";
              };

              "uBlock0@raymondhill.net" = {
                disableFirstRunPage = true;
                rulesets = [
                  "-*"
                  "+default"
                  "adguard-cookies"
                  "ublock-cookies-adguard"
                  "NLD-0"
                  "adguard-spyware"
                  "adguard-spyware-url"
                ];
              };
            };
          };
        };
      };
    };
  };
}
