{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.desktop.apps.vencord;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.vencord = {
      enable = mkEnableOption "Vencord";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {inputs, ...}: {
      imports = [
        inputs.nixcord.homeModules.nixcord
      ];

      programs.nixcord = {
        enable = true;
        discord = {
          enable = true;
          vencord.enable = true;
          krisp.enable = true;

          # OpenASAR hangs this host's client on the "Starting..." splash.
          openASAR.enable = false;
        };

        vesktop.enable = false;

        # Ships with this repo; see plugins/auto-game-go-live/index.ts. Pairs with
        # tiebe.desktop.hyprland.sharePicker, which answers the portal with the
        # running game, so one click on Discord's screen share button streams it.
        userPlugins = {
          AutoGameGoLive = ./plugins/auto-game-go-live;
        };

        # Userplugins are not part of nixcord's typed plugin schema.
        extraConfig = {
          plugins.AutoGameGoLive.enabled = true;
        };

        config.plugins = {
          betterGifAltText.enable = true;
          betterSessions.enable = true;
          betterSettings.enable = true;
          biggerStreamPreview.enable = true;
          callTimer.enable = true;
          clearUrls.enable = true;
          copyEmojiMarkdown.enable = true;
          copyFileContents.enable = true;
          copyUserUrls.enable = true;
          expressionCloner.enable = true;
          fakeNitro.enable = true;
          fixImagesQuality.enable = true;
          fixSpotifyEmbeds.enable = true;
          forceOwnerCrown.enable = true;
          fullSearchContext.enable = true;
          gameActivityToggle.enable = true;
          greetStickerPicker.enable = true;
          imageZoom.enable = true;
          memberCount.enable = true;
          mentionAvatars.enable = true;
          messageClickActions.enable = true;
          messageLogger.enable = true;
          mutualGroupDms.enable = true;
          openInApp.enable = true;
          permissionsViewer.enable = true;
          platformIndicators.enable = true;
          userMessagesPronouns.enable = true;
          readAllNotificationsButton.enable = true;
          relationshipNotifier.enable = true;
          reviewDb.enable = true;
          serverInfo.enable = true;
          shikiCodeblocks.enable = true;
          showConnections.enable = true;
          showHiddenChannels.enable = true;
          showHiddenThings.enable = true;
          spotifyControls.enable = true;
          typingIndicator.enable = true;
          typingTweaks.enable = true;
          unindent.enable = true;
          userVoiceShow.enable = true;
          validReply.enable = true;
          validUser.enable = true;
          viewRaw.enable = true;
          volumeBooster.enable = true;
          whoReacted.enable = true;
          youtubeAdblock.enable = true;
          webScreenShareFixes.enable = true;
          webKeybinds.enable = true;
        };
      };

      services.arrpc.enable = false;
    };
  };
}
