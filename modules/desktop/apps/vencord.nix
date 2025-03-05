{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.vencord;
in {
  options = {
    tiebe.desktop.apps.vencord = {
      enable = mkEnableOption "Vencord";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {inputs, ...}: {
      imports = [
        inputs.nixcord.homeManagerModules.nixcord
      ];

      programs.nixcord = {
        enable = true;
        discord.enable = false;

        vesktop.enable = true;

        config.plugins = {
          betterGifAltText.enable = true;
          betterSessions.enable = true;
          betterSettings.enable = true;
          biggerStreamPreview.enable = true;
          callTimer.enable = true;
          clearURLs.enable = true;
          copyEmojiMarkdown.enable = true;
          copyFileContents.enable = true;
          copyUserURLs.enable = true;
          emoteCloner.enable = true;
          fakeNitro.enable = true;
          fixImagesQuality.enable = true;
          fixSpotifyEmbeds.enable = true;
          forceOwnerCrown.enable = true;
          friendsSince.enable = true;
          fullSearchContext.enable = true;
          gameActivityToggle.enable = true;
          greetStickerPicker.enable = true;
          imageZoom.enable = true;
          memberCount.enable = true;
          mentionAvatars.enable = true;
          messageClickActions.enable = true;
          messageLogger.enable = true;
          mutualGroupDMs.enable = true;
          openInApp.enable = true;
          permissionsViewer.enable = true;
          platformIndicators.enable = true;
          userMessagesPronouns.enable = true;
          readAllNotificationsButton.enable = true;
          relationshipNotifier.enable = true;
          reviewDB.enable = true;
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

      stylix.targets.vesktop.enable = false;
      services.arrpc.enable = true;
    };
  };
}
