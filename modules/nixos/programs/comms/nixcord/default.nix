{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.my.user.username;
in
{
  imports = [ inputs.nixcord.nixosModules.nixcord ];

  programs.nixcord = {
    enable = config.my.programs.comms.enable;
    discord.enable = true;
    # Note: nixcord now requires an explicit client mod selection.
    discord.vencord.enable = true;
    # Disable openASAR while its nixpkgs substituteStream pattern is broken.
    discord.openASAR.enable = false;

    user = username;

    quickCss =
      let
        colors = config.lib.stylix.colors.withHashtag;
      in
      ''
        @import url('https://refact0r.github.io/system24/build/system24.css');

        body {
          --font: 'DM Mono';
          --code-font: 'DM Mono';
          font-weight: 300;
          letter-spacing: -0.05ch;

          --gap: 12px;
          --divider-thickness: 4px;
          --border-thickness: 2px;
          --border-hover-transition: 0.2s ease;

          --animations: on;
          --list-item-transition: 0.2s ease;
          --dms-icon-svg-transition: 0.4s ease;

          --top-bar-height: var(--gap);
          --top-bar-button-position: titlebar;
          --top-bar-title-position: off;
          --subtle-top-bar-title: off;

          --small-user-panel: on;
          --unrounding: on;
          --round-pfp: off;
          --remove-pfp-decor: off;

          --custom-spotify-bar: on;
          --ascii-titles: on;
          --ascii-loader: system24;

          --panel-labels: on;
          --label-color: var(--text-muted);
          --label-font-weight: 500;
        }

        :root {
          --colors: on;

          --text-0: var(--bg-3);
          --text-1: ${colors.base06};
          --text-2: ${colors.base05};
          --text-3: ${colors.base04};
          --text-4: ${colors.base04};
          --text-5: ${colors.base03};

          --bg-1: ${colors.base02};
          --bg-2: ${colors.base01};
          --bg-3: ${colors.base01};
          --bg-4: ${colors.base00};
          --hover: color-mix(in srgb, ${colors.base04} 10%, transparent);
          --active: color-mix(in srgb, ${colors.base04} 20%, transparent);
          --active-2: color-mix(in srgb, ${colors.base04} 30%, transparent);
          --message-hover: color-mix(in srgb, ${colors.base00} 20%, transparent);

          --accent-1: ${colors.base0C};
          --accent-2: ${colors.base0D};
          --accent-3: ${colors.base0D};
          --accent-4: ${colors.base0C};
          --accent-5: ${colors.base0E};
          --accent-new: var(--accent-2);
          --mention: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 90%) 40%, transparent);
          --mention-hover: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 95%) 40%, transparent);
          --reply: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 90%) 40%, transparent);
          --reply-hover: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 95%) 40%, transparent);

          --online: ${colors.base0B};
          --dnd: ${colors.base08};
          --idle: ${colors.base0A};
          --streaming: ${colors.base0E};
          --offline: var(--text-4);

          --border-light: color-mix(in srgb, ${colors.base03} 35%, transparent);
          --border: color-mix(in srgb, ${colors.base03} 60%, transparent);
          --border-hover: var(--accent-2);
          --button-border: color-mix(in srgb, ${colors.base05} 15%, transparent);
        }
      '';

    config = {
      useQuickCss = true;
      plugins = {
        alwaysExpandRoles.enable = true;
        betterGifPicker.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        betterFolders.enable = true;
        biggerStreamPreview.enable = true;
        callTimer = {
          enable = true;
          format = "human";
        };
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
        fullSearchContext.enable = true;
        gameActivityToggle.enable = true;
        gifPaste.enable = true;
        greetStickerPicker.enable = true;
        hideMedia.enable = true;
        ignoreActivities = {
          enable = true;
          ignoreListening = false;
          ignoreWatching = true;
          ignoreCompeting = true;
        };
        imageZoom = {
          enable = true;
          size = 500.0;
          zoom = 2.0;
        };
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
        pinDms.enable = true;
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
          {
            find = "https?:\\/\\/(www\\.)?instagram\\.com\\/[^\\/]+\\/(p|reel)\\/([A-Za-z0-9-_]+)\\/?";
            replace = "https://g.ddinstagram.com/$2/$3";
          }
          {
            find = "https:\\/\\/x\\.com\\/([^\\/]+\\/status\\/[0-9]+)";
            replace = "https://vxtwitter.com/$1";
          }
          {
            find = "https:\\/\\/twitter\\.com\\/([^\\/]+\\/status\\/[0-9]+)";
            replace = "https://vxtwitter.com/$1";
          }
          {
            find = "https:\\/\\/(www\\.)?tiktok\\.com\\/(.*)";
            replace = "https://vxtiktok.com/$2";
          }
          {
            find = "https:\\/\\/(www\\.|old\\.)?reddit\\.com\\/(r\\/[a-zA-Z0-9_]+\\/comments\\/[a-zA-Z0-9_]+\\/[^\\s]*)";
            replace = "https://vxreddit.com/$2";
          }
          {
            find = "https:\\/\\/(www\\.)?pixiv\\.net\\/(.*)";
            replace = "https://phixiv.net/$2";
          }
          {
            find = "https:\\/\\/(?:www\\.|m\\.)?twitch\\.tv\\/twitch\\/clip\\/(.*)";
            replace = "https://clips.fxtwitch.tv/$1";
          }
          {
            find = "https:\\/\\/(?:www\\.)?youtube\\.com\\/(?:watch\\?v=|shorts\\/)([a-zA-Z0-9_-]+)";
            replace = "https://youtu.be/$1";
          }
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
}
