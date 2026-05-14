{ self, inputs, ... }:
{
  flake.nixosModules.applicationsCommsNixcord =
    { config, lib, ... }:
    let
      username = config.userOptions.username;
    in
    {
      home-manager.users.${username} = {
        imports = [ inputs.nixcord.homeModules.nixcord ];
        stylix.targets.nixcord.enable = false;
        programs.nixcord = {
          enable = true;
          #discord.enable = lib.mkDefault true;
          equibop.enable = lib.mkDefault true;
          config = {
            themeLinks = [
              "https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-nord.theme.css"
            ];
            plugins = {
              alwaysExpandRoles.enable = true;
              betterGifPicker.enable = true;
              betterSettings.enable = true;
              betterUploadButton.enable = true;
              betterFolders.enable = true;
              biggerStreamPreview.enable = true;
              callTimer = { enable = true; format = "human"; };
              crashHandler.enable = true;
              disableCallIdle.enable = true;
              dontRoundMyTimestamps.enable = true;
              expressionCloner.enable = true;
              fakeNitro.enable = true;
              favoriteEmojiFirst.enable = true;
              fixCodeblockGap.enable = true;
              fixImagesQuality.enable = true;
              fixYoutubeEmbeds.enable = true;
              forceOwnerCrown.enable = true;
              friendsSince.enable = true;
              fullSearchContext.enable = true;
              gameActivityToggle.enable = true;
              gifPaste.enable = true;
              greetStickerPicker.enable = true;
              hideMedia.enable = true;
              ignoreActivities = {
                enable = true;
                ignoreListening = true;
                ignoreWatching = true;
                ignoreCompeting = true;
              };
              imageZoom = { enable = true; size = 500.0; zoom = 2.0; };
              memberCount.enable = true;
              mentionAvatars.enable = true;
              messageLatency.enable = true;
              messageLogger = {
                enable = true;
                collapseDeleted = true;
                ignoreSelf = true;
                ignoreBots = true;
              };
              newGuildSettings.enable = true;
              noBlockedMessages.enable = true;
              noDevtoolsWarning.enable = true;
              noF1.enable = true;
              noMaskedUrlPaste.enable = true;
              noMosaic.enable = true;
              noPendingCount.enable = true;
              noProfileThemes.enable = true;
              noTypingAnimation.enable = true;
              noUnblockToJump.enable = true;
              oneko.enable = true;
              pauseInvitesForever.enable = true;
              pictureInPicture.enable = true;
              PinDMs.enable = true;
              platformIndicators.enable = true;
              previewMessage.enable = true;
              readAllNotificationsButton.enable = true;
              replyTimestamp.enable = true;
              revealAllSpoilers.enable = true;
              serverInfo.enable = true;
              serverListIndicators.enable = true;
              showConnections.enable = true;
              showHiddenThings.enable = true;
              showMeYourName.enable = true;
              showTimeoutDuration.enable = true;
              silentTyping.enable = true;
              streamerModeOnStream.enable = true;
              textReplace.enable = true;
              textReplace.regexRules = [
                { find = "https?:\\/\\/(www\\.)?instagram\\.com\\/[^\\/]+\\/(p|reel)\\/([A-Za-z0-9-_]+)\\/?"; replace = "https://g.ddinstagram.com/$2/$3"; }
                { find = "https:\\/\\/x\\.com\\/([^\\/]+\\/status\\/[0-9]+)"; replace = "https://vxtwitter.com/$1"; }
                { find = "https:\\/\\/twitter\\.com\\/([^\\/]+\\/status\\/[0-9]+)"; replace = "https://vxtwitter.com/$1"; }
                { find = "https:\\/\\/(www\\.)?tiktok\\.com\\/(.*)"; replace = "https://vxtiktok.com/$2"; }
                { find = "https:\\/\\/(www\\.|old\\.)?reddit\\.com\\/(r\\/[a-zA-Z0-9_]+\\/comments\\/[a-zA-Z0-9_]+\\/[^\\s]*)"; replace = "https://vxreddit.com/$2"; }
                { find = "https:\\/\\/(www\\.)?pixiv\\.net\\/(.*)"; replace = "https://phixiv.net/$2"; }
                { find = "https:\\/\\/(?:www\\.|m\\.)?twitch\\.tv\\/twitch\\/clip\\/(.*)"; replace = "https://clips.fxtwitch.tv/$1"; }
                { find = "https:\\/\\/(?:www\\.)?youtube\\.com\\/(?:watch\\?v=|shorts\\/)([a-zA-Z0-9_-]+)"; replace = "https://youtu.be/$1"; }
              ];
              themeAttributes.enable = true;
              translate.enable = true;
              unindent.enable = true;
              unlockedAvatarZoom.enable = true;
              userVoiceShow.enable = true;
              validReply.enable = true;
              validUser.enable = true;
              vencordToolbox.enable = true;
              viewIcons.enable = true;
              voiceChatDoubleClick.enable = true;
              volumeBooster.enable = true;
              youtubeAdblock.enable = true;
            };
          };
        };
      };
    };
}
