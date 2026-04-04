{
  # Application & system config — cleaned from legacy Breeze/default values
  programs.plasma.configFile = {
    # ── Baloo ──────────────────────────────────────────────────────
    "baloofilerc"."General"."dbVersion" = 2;
    "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
    "baloofilerc"."General"."exclude filters version" = 9;

    # ── Dolphin ────────────────────────────────────────────────────
    "dolphinrc"."General"."ViewPropsTimestamp" = "2024,3,19,15,27,9.542";
    "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
    "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;

    # ── Activity manager ───────────────────────────────────────────
    "kactivitymanagerdrc"."activities"."2903de61-3d4a-4b4f-bc64-c400afdb965e" = "Default";
    "kactivitymanagerdrc"."main"."currentActivity" = "2903de61-3d4a-4b4f-bc64-c400afdb965e";

    # ── Kate ───────────────────────────────────────────────────────
    "katerc"."General"."Days Meta Infos" = 30;
    "katerc"."General"."Save Meta Infos" = true;
    "katerc"."General"."Show Full Path in Title" = false;
    "katerc"."General"."Show Menu Bar" = true;
    "katerc"."General"."Show Status Bar" = true;
    "katerc"."General"."Show Tab Bar" = true;
    "katerc"."General"."Show Url Nav Bar" = true;
    "katerc"."KTextEditor Renderer"."Animate Bracket Matching" = false;
    "katerc"."KTextEditor Renderer"."Auto Color Theme Selection" = true;
    "katerc"."KTextEditor Renderer"."Color Theme" = "Catppuccin Mocha";
    "katerc"."KTextEditor Renderer"."Line Height Multiplier" = 1;
    "katerc"."KTextEditor Renderer"."Show Indentation Lines" = false;
    "katerc"."KTextEditor Renderer"."Show Whole Bracket Expression" = false;
    "katerc"."KTextEditor Renderer"."Text Font" = "JetBrainsMono Nerd Font,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1";
    "katerc"."KTextEditor Renderer"."Word Wrap Marker" = false;
    "katerc"."filetree"."editShade" = "31,81,106";
    "katerc"."filetree"."listMode" = false;
    "katerc"."filetree"."middleClickToClose" = false;
    "katerc"."filetree"."shadingEnabled" = true;
    "katerc"."filetree"."showCloseButton" = false;
    "katerc"."filetree"."showFullPathOnRoots" = false;
    "katerc"."filetree"."showToolbar" = true;
    "katerc"."filetree"."sortRole" = 0;
    "katerc"."filetree"."viewShade" = "81,49,95";

    # ── Input ──────────────────────────────────────────────────────
    "kcminputrc"."Libinput/1133/50504/Logitech USB Receiver Mouse"."PointerAcceleration" = "-0.400";
    "kcminputrc"."Libinput/1133/50504/Logitech USB Receiver Mouse"."PointerAccelerationProfile" = 2;
    "kcminputrc"."Libinput/1133/50504/Logitech USB Receiver Mouse"."ScrollFactor" = 0.5;
    "kcminputrc"."Libinput/12972/6/FRMW0004:00 32AC:0006 Consumer Control"."NaturalScroll" = false;
    "kcminputrc"."Libinput/2362/628/PIXA3854:00 093A:0274 Touchpad"."NaturalScroll" = true;

    # ── KDE daemon ─────────────────────────────────────────────────
    "kded5rc"."Module-device_automounter"."autoload" = false;

    # ── KDE globals ────────────────────────────────────────────────
    "kdeglobals"."DirSelect Dialog"."DirSelectDialog Size" = "818,584";
    "kdeglobals"."DirSelect Dialog"."Splitter State" = "x00x00x00xffx00x00x00x01x00x00x00x02x00x00x00x8cx00x00x02xa8x00xffxffxffxffx01x00x00x00x01x00";
    "kdeglobals"."General"."AllowKDEAppsToRememberWindowPositions" = true;
    "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
    "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
    "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
    "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
    "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
    "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
    "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
    "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
    "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
    "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
    "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
    "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
    "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
    "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
    "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
    "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
    "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 140;
    "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
    "kdeglobals"."Shortcuts"."Quit" = "Meta+Q";
    # NOTE: Removed kdeglobals.WM.* Breeze Light colors — now managed by CatppuccinMochaBlue color scheme

    # ── Misc ───────────────────────────────────────────────────────
    "kiorc"."Confirmations"."ConfirmDelete" = true;
    "kscreenlockerrc"."Daemon"."Autolock" = false;
    "ksmserverrc"."General"."loginMode" = "emptySession";
    "kwalletrc"."Wallet"."Default Wallet" = "Default keyring";
    "kwalletrc"."Wallet"."First Use" = false;

    # NOTE: Removed kwinrc.Desktops/Tiling UUID entries — now managed by kwin.nix virtualDesktops
    # NOTE: Removed plasmarc.Theme.name = "default" — now managed by workspace colorScheme

    "kwinrc"."Xwayland"."Scale" = 1.35;
    "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";

    # ── Notifications ──────────────────────────────────────────────
    "plasmanotifyrc"."Applications/discord"."Seen" = true;
    "plasmanotifyrc"."Applications/firefox"."Seen" = true;
    "plasmanotifyrc"."Applications/thunderbird"."Seen" = true;
    "plasmanotifyrc"."Applications/vesktop"."Seen" = true;

    # ── Spectacle ──────────────────────────────────────────────────
    "spectaclerc"."General"."clipboardGroup" = "PostScreenshotCopyImage";
    "spectaclerc"."General"."launchAction" = "UseLastUsedCapturemode";
    "spectaclerc"."GuiConfig"."captureMode" = 0;
    "spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Screenshots";
    "spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Screencasts";
  };
}
