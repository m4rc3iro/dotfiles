------------------------------------------------------------------------
-- Imports
import Control.Monad (liftM2)
import Data.Ratio
import Data.Maybe (fromJust, isJust)
import qualified Data.Map as M
import qualified Data.Map.Strict as Map
-- Graphics modifiers
import Graphics.X11.ExtraTypes.XF86
-- System modifiers
import System.IO
import System.Exit

import XMonad hiding ( (|||) )  -- don't use the normal ||| operator, use the LayoutCombinators one
-- Action modifiers
import XMonad.Actions.CycleWS
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.WithAll (sinkAll, killAll)
-- Hooks modifiers
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.InsertPosition -- attachaside hook, like dwm's
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (isFullscreen, doRectFloat, doFullFloat, doCenterFloat)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
-- Layouts modifiers
import XMonad.Layout.Fullscreen
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.LayoutCombinators -- use the one from LayoutCombinators instead
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import qualified XMonad.Layout.Magnifier as Mag
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
-- import XMonad.Layout.NoBorders
import XMonad.Layout.Named
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ShowWName
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import XMonad.Layout.NoBorders (noBorders, smartBorders)

-- Util modifiers
import XMonad.Util.Cursor
import XMonad.Util.NamedScratchpad as NS
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.SpawnOnce
-- Qualified modifiers
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.StackSet as W
import qualified Data.Map as M


------------------------------------------------------------------------
-- Variables
--
myFocusFollowsMouse :: Bool

myModMask     = mod4Mask
myTerminal    = "alacritty"
myBrowser    = "chromium"
myScreensaver = "/usr/bin/slock"
mySelectScreenshot = "$TERMINAL -e flameshot gui"
myLauncher = "dmenu_run -p 'Run: '"
myFileExplorer = "pcmanfm"
ranger = "$TERMINAL -t ranger -e ranger"
neomutt = "$TERMINAL -t neomutt -e neomutt"
calendar = "$TERMINAL -t calendar -e calcurse"
toolboxCmd = "$TERMINAL -e bmenu"
systemSettingsCmd = "$TERMINAL -e system-settings"
packageManagerUICmd = "$TERMINAL -e pacui"
myXmobarrc = "~/.xmonad/xmobarrc"
myNormalBorderColor  = "#444444" --old greyish style
myFocusedBorderColor = "#e35155" -- manjaro green color
-- myFocusedBorderColor = "#e35155" -- redish color
-- myFocusedBorderColor = "#8fb774" -- greenish color
myFocusFollowsMouse = True
myBorderWidth = 1
xmobarTitleColor = "#bbbbbb"
xmobarEmptyWSColor = "#cfa881"
xmobarCurrentWorkspaceColor = "#8fb774"
myKeybindingsCmd = "$TERMINAL -e | ~/.xmonad/xmonad_keys.sh &>/dev/null" -- '&>/dev/null' means no shell output
myWhatsApp = "whatsapp-for-linux"

intern = "eDP1"
extern = "HDMI2"
output2acerCmd = "$TERMINAL -e xrandr --output " ++ intern ++ " --off --output " ++ extern ++ "--mode 1920x1080"
output2eizoCmd = "xrandr --output " ++ intern ++ " --off --output " ++ extern ++ "--mode 2560x1440"

------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
myStartupHook :: X ()
myStartupHook = do
        -- spawnOnce "mate-power-manager"
        spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
        spawnOnce "setxkbmap -layout us,es -option grp:shifts_toggle -variant mac" -- switch keyboard layouts 'us-es' (press both Shift keys at once)
        spawnOnce "nitrogen --restore"
        setDefaultCursor xC_left_ptr -- sets default cursor theme which was not applied on startup
        spawnOnce "clipmenud"
        spawnOnce "picom"
        spawnOnce "redshift"
        setWMName "LG3D" -- fixes rendering issues with Java based applications


myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "calculator" spawnCalc findCalc manageCalc 
                , NS "ranger" spawnRanger findRanger manageRanger 
                , NS "spotify" spawnSpotify findSpotify manageSpotify 
                , NS "blueman" spawnBlueman findBlueman manageBlueman ]
    where 
        spawnCalc = "qalculate-gtk"
        findCalc   = className =? "Qalculate-gtk"
        manageCalc = customFloating $ W.RationalRect l t w h -- h:heigh,w:width,t:latitud,l:longitud
                   where
                     h = 0.4
                     w = 0.4
                     t = 0.6 -h
                     l = 0.6 -w

        spawnRanger  = "$TERMINAL -t ranger-nsp -e ranger"
        findRanger   = title =? "ranger-nsp"
        manageRanger = customFloating $ W.RationalRect l t w h -- h:heigh,w:width,t:latitud,l:longitud
                    where
                        h = 0.5
                        w = 0.5
                        t = 0.7 -h 
                        l = 0.7 -w
        
        spawnSpotify  = "spotify"
        findSpotify   = className =? "Spotify"
        manageSpotify = customFloating $ W.RationalRect l t w h -- h:heigh,w:width,t:latitud,l:longitud
                    where
                        h = 0.6
                        w = 0.6
                        t = 0.8 -h 
                        l = 0.8 -w

        spawnBlueman  = "blueman-manager"
        findBlueman   = className =? "Blueman-manager"
        manageBlueman = customFloating $ W.RationalRect l t w h -- h:heigh,w:width,t:latitud,l:longitud
                    where
                        h = 0.5
                        w = 0.5
                        t = 0.7 -h 
                        l = 0.7 -w

------------------------------------------------------------------------
-- Workspaces

myWorkspaces = ["ini","dev","sms","dir","sys","mus","scm","prd","www"]
myWorkspaceIndices = Map.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ Map.lookup ws myWorkspaceIndices


------------------------------------------------------------------------
-- Window rules
--
myManageHook = composeAll [
      className =? "Atom" --> viewShift "dev"
    , className =? "Subl" --> viewShift "dev"
    , className =? "SmartGit" --> viewShift "dev"
    , className =? "Pcmanfm" --> viewShift "dir"
    , title =? "ranger" --> viewShift "dir"
    , className =? "Whatsapp-for-linux" --> viewShift "sms"
    , className =? "whatsapp-nativefier-d40211" --> viewShift "sms"
    , className =? "TelegramDesktop" --> viewShift "sms" 
    , className =? "discord" --> viewShift "scm" 
    , className =? "twitter-nativefier-4fd9c9" --> viewShift "scm"
    , className =? "Brave-browser" --> viewShift "www"
    , className =? "Chromium" --> viewShift "www"
    , className =? "firefox" --> viewShift "www"
    , className =? "Trello" --> viewShift "prd"
    , className =? "notion-app" --> viewShift "prd"
    , className =? "shortwave" --> viewShift "mus"
    -- do float the following apps
    , title =? "Gimp" --> doFloat
    , className =? "Yad" --> doCenterFloat
    , className =? "VirtualBox" --> doFloat
    -- , className =? "Gnome-calculator" --> doRectFloat (W.RationalRect 1 1 (0.75 -0.5) (0.70 -0.4))
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ] <+> namedScratchpadManageHook myScratchPads
  where viewShift = doF . liftM2 (.) W.greedyView W.shift


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
mySpacingWidth = 2

myTallLayout = named "||=" 
              $ Mag.magnifierOff 
              $ mySpacing mySpacingWidth 
              $ Tall 1 (3/100) (1/2) 

myMirrorTallLayout = named "LLL" 
                    $ Mag.magnifierOff
                    $ mySpacing mySpacingWidth 
                    $ Mirror (Tall 1 (3/100) (3/5))

myCenteredMasterLayout = named "=||=" 
                        $ Mag.magnifierOff
                        $ mySpacing mySpacingWidth 
                        $ ThreeColMid 1 (3/100) (3/5)

myMonocleLayout = named "|M|" 
                  $ mySpacing mySpacingWidth 
                  $ Full

mySpiralLayout = named "(@)"
                $ Mag.magnifierOff 
                $ mySpacing mySpacingWidth 
                $ spiral (6/7)

myThreeRows = named "===" 
              $ Mag.magnifierOff
              $ mySpacing mySpacingWidth 
              $ Mirror 
              $ ThreeCol 1 (3/100) (3/5)

myGrid = named "###" 
        $ Mag.magnifierOff
        $ mySpacing mySpacingWidth 
        $ limitWindows 12 
        $ mkToggle (single MIRROR) 
        $ Grid (16/10) 

spirals = named "spirals" 
          $ Mag.magnifierOff
          $ mySpacing 0 
          $ spiral (6/7)

floats = named "><>" 
        $ mySpacing mySpacingWidth 
        $ limitWindows 12 simplestFloat

threeCol = named "threeCol" 
          $ Mag.magnifierOff
          $ limitWindows 7 
          $ mySpacing 0 
          $ ThreeCol 1 (3/100) (1/2)

threeRow = named "threeRow" 
          $ Mag.magnifierOff
          $ limitWindows 7 
          $ mySpacing 0 
          $ Mirror 
          $ ThreeCol 1 (3/100) (1/2)

myTabs = named "TTT" 
        $ mySpacing mySpacingWidth 
        $ tabbed shrinkText myTabConfig
  where
    myTabConfig = def { fontName            = "xft:FreeMono:size=9:antialias=true:hinting=true"
                      , activeColor         = "#282828"
                      , inactiveColor       = "#282828" -- "#3e445e"
                      , activeBorderColor   = myFocusedBorderColor
                      , inactiveBorderColor = "#646464"
                      , activeTextColor     = xmobarTitleColor
                      , inactiveTextColor   = xmobarTitleColor
                      }

myLayout = avoidStruts $ 
           onWorkspace "www" ( myMonocleLayout
                                ||| myTallLayout
                                ||| myMirrorTallLayout
                                ||| myGrid
                                ||| myCenteredMasterLayout
                                ||| myThreeRows
                                ||| myTabs
                                ||| floats ) $ 
           mkToggle (NBFULL ?? NOBORDERS ?? EOT)
                      ( myTallLayout --magnifier (myTallLayout)
                        ||| myMirrorTallLayout
                        ||| myMonocleLayout
                        ||| myGrid
                        ||| myCenteredMasterLayout
                        -- ||| mySpiralLayout
                        ||| myThreeRows
                        ||| myTabs
                        ||| floats )

------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
-- nextNonEmptyWS = findWorkspace getSortByIndexNoSP Next HiddenNonEmptyWS 1
--         >>= \t -> (windows . W.view $ t)
-- prevNonEmptyWS = findWorkspace getSortByIndexNoSP Prev HiddenNonEmptyWS 1
--         >>= \t -> (windows . W.view $ t)

nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ---------------------------------------------------------------------- START_KEYS
  -- Application launch keybindings
  --
  [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
  , ((modMask, xK_Return), spawn myLauncher)
  , ((modMask .|. controlMask, xK_F4), spawn mySelectScreenshot) -- Take a selective screenshot using custom command
  , ((modMask .|. shiftMask, xK_b), spawn myBrowser) -- launch default browser
  , ((modMask, xK_b), spawn "brave") -- launch default browser
  -- , ((modMask .|. shiftMask, xK_m), spawn neomutt)
  --  , ((modMask .|. shiftMask, xK_c), spawn calculator)
  , ((modMask .|. shiftMask, xK_c), spawn "clipmenu")
  , ((modMask .|. shiftMask, xK_p), spawn "trello")
  , ((modMask .|. shiftMask, xK_w), spawn "twitter-nativefier")
  , ((modMask .|. shiftMask, xK_o), spawn myWhatsApp)
  , ((modMask, xK_o), spawn "telegram-desktop")
  , ((modMask .|. shiftMask, xK_i), spawn "subl")
  -- , ((controlMask.|. shiftMask, xK_c), spawn "clipmenu")
  -- , ((modMask .|. shiftMask, xK_u), spawn "smartgit")
  , ((modMask .|. shiftMask, xK_n), spawn "notion-app")
  -- , ((modMask, xK_e), spawn myFileExplorer) -- pcmanfm
  , ((modMask .|. shiftMask, xK_e), spawn ranger)
  -- , ((modMask .|. controlMask, xK_m), spawn "geary")
  , ((modMask .|. controlMask, xK_t), spawn toolboxCmd)
  , ((modMask .|. controlMask, xK_y), spawn systemSettingsCmd)
  , ((modMask .|. controlMask, xK_p), spawn packageManagerUICmd)
  --------------------------------------------------------------------
  -- Control key functions
  , ((0, xF86XK_AudioMute), spawn "amixer -q set Master toggle")
  , ((0, xF86XK_AudioLowerVolume), spawn "amixer -q set Master 7.5%-")
  -- , ((0, xF86XK_AudioLowerVolume), spawn "pactl -- set-sink-volume 2 -15%")
  , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 7.5%+")
  -- , ((0, xF86XK_AudioRaiseVolume), spawn "pactl -- set-sink-volume 2 +15%")
  , ((0, xF86XK_AudioPrev), spawn "playerctl previous")
  , ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
  , ((0, xF86XK_AudioNext), spawn "playerctl next")
  , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
  , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
  , ((0, xF86XK_KbdBrightnessUp), spawn "~/.local/bin/scripts/kbdbacklight up")
  , ((0, xF86XK_KbdBrightnessDown), spawn "~/.local/bin/scripts/kbdbacklight down")
  --------------------------------------------------------------------
  -- Layouts key bindings
  , ((modMask, xK_q), kill) -- Kill the currently focused client
  , ((modMask, xK_a), killAll) -- Kill all windows in the current workspace
  , ((modMask, xK_t), sendMessage $ JumpToLayout "||=")
  , ((modMask .|. shiftMask, xK_t), sendMessage $ JumpToLayout "LLL")
  , ((modMask, xK_m), sendMessage $ JumpToLayout "|M|")
  , ((modMask .|. shiftMask, xK_m), sendMessage Mag.Toggle)
  , ((modMask, xK_u), sendMessage $ JumpToLayout "===")
  , ((modMask .|. shiftMask, xK_u), sendMessage $ JumpToLayout "###")
  , ((modMask, xK_y), sendMessage $ JumpToLayout "=||=")
  , ((modMask .|. shiftMask, xK_y), sendMessage $ JumpToLayout "TTT")
  -- , ((modMask, xK_y), sendMessage $ JumpToLayout "(@)")
  -- , ((modMask .|. shiftMask, xK_u), sendMessage $ JumpToLayout "---")
  , ((modMask, xK_space), sendMessage NextLayout) -- Cycle through the available layout algorithms
  , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf) -- Resets current workspace layouts to default
  , ((modMask, xK_f), sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
  , ((modMask .|. shiftMask, xK_f), sendMessage $ JumpToLayout "><>")
  , ((modMask, xK_s), withFocused $ windows . W.sink) -- Push window back into tiling
  , ((modMask .|. shiftMask, xK_s), sinkAll) -- Push all windows back into tiling
  --------------------------------------------------------------------
  -- Scratchpads 
  , ((modMask, xK_c), namedScratchpadAction myScratchPads "calculator")
  , ((modMask, xK_e), namedScratchpadAction myScratchPads "ranger")
  , ((modMask .|. shiftMask, xK_g), namedScratchpadAction myScratchPads "spotify")
  , ((modMask .|. controlMask, xK_b), namedScratchpadAction myScratchPads "blueman")
  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  -- Resize viewed windows to the correct size.
  -- , ((modMask, xK_r), refresh)
  , ((modMask, xK_Tab), windows W.focusDown) -- Move focus to the next window
  , ((modMask, xK_j), windows W.focusDown) -- Move focus to the next window
  , ((modMask, xK_Down), windows W.focusDown)
  , ((modMask, xK_k), windows W.focusUp) -- Move focus to the previous window
  , ((modMask, xK_Up), windows W.focusUp)
  , ((modMask, xK_n), windows W.focusMaster) -- Move focus to the master window
  , ((modMask, xK_semicolon), windows W.swapMaster) -- Swap the focused window and the master window
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown) -- Swap the focused window with the next window
  , ((modMask .|. shiftMask, xK_Down), windows W.swapDown) 
  , ((modMask .|. shiftMask, xK_k), windows W.swapUp) -- Swap the focused window with the previous window
  , ((modMask .|. shiftMask, xK_Up), windows W.swapUp) 
  , ((modMask .|. shiftMask, xK_h), sendMessage Shrink) -- Shrink the master area
  , ((modMask .|. shiftMask, xK_Left), sendMessage Shrink) 
  , ((modMask .|. shiftMask, xK_l), sendMessage Expand) -- Expand the master area
  , ((modMask .|. shiftMask, xK_Right), sendMessage Expand) 

  , ((modMask, xK_i), sendMessage (IncMasterN 1)) -- Increment the number of windows in the master area
  , ((modMask, xK_d), sendMessage (IncMasterN (-1))) -- Decrement the number of windows in the master area
  , ((modMask, xK_h), moveTo Prev nonEmptyNonNSP) -- Move focus to the previous worskpace
  , ((modMask, xK_Left), moveTo Prev nonEmptyNonNSP)
  , ((modMask, xK_l), moveTo Next nonEmptyNonNSP) -- Move focus to the previous workspace
  , ((modMask, xK_Right), moveTo Next nonEmptyNonNSP) 
  , ((modMask,  xK_period), nextScreen) -- Move focus to the next screen
  -- , ((modMask .|. shiftMask,  xK_Right), nextScreen) 
  , ((modMask,  xK_comma), prevScreen) -- Move focus to the previous screen
  -- , ((modMask .|. shiftMask,  xK_Left), prevScreen) 
  , ((modMask .|. shiftMask, xK_period), shiftNextScreen) -- Move window to the next screen
  -- , ((modMask .|. shiftMask, xK_Down), shiftNextScreen) 
  , ((modMask .|. shiftMask, xK_comma), shiftPrevScreen) -- Move window to the previous screen
  -- , ((modMask .|. shiftMask, xK_Up), shiftPrevScreen) 
  , ((modMask, xK_Tab), toggleWS' ["NSP"]) -- Toggle through most recent workspaces (excluding scratchpads)

  , ((0, xK_F4), spawn "autorandr --change --default mobile") -- Refresh display config
  , ((0, xK_F5), spawn "~/.local/bin/scripts/monitorSetupDialog.sh acer")-- Set output to Acer monitor
  , ((0, xK_F6), spawn "~/.local/bin/scripts/monitorSetupDialog.sh eizo")-- Set output to Eizo monitor
  , ((modMask, xK_F4), spawn "~/.local/bin/scripts/monitorSetupDialog.sh") -- Set display config
  , ((modMask, xK_equal), spawn "networkmenu.sh") -- Network Manger settings
  , ((modMask .|. controlMask, xK_l), spawn "/usr/bin/slock") -- lock screen
  , ((modMask .|. controlMask, xK_s), spawn "systemctl suspend") -- Suspend
  , ((modMask .|. controlMask, xK_r), spawn "reboot") -- Reboot
  , ((modMask .|. controlMask, xK_x), spawn "shutdown -h now") -- Shutdown
  , ((modMask .|. controlMask, xK_q), spawn "~/.local/bin/scripts/exitDialog.sh") -- Power options general script
  , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess)) -- Quit xmonad
  -- , ((modMask .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart") -- Restart xmonad
  , ((modMask .|. shiftMask, xK_r), spawn "xmonad --restart") -- Restart xmonad
  , ((modMask .|. shiftMask, xK_slash), spawn myKeybindingsCmd) -- shows dialog with my keybindinds
  ] -- END_KEYS
  ++
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++
  -- Swap worspaces: if you're on workspace 1, hitting mod-ctrl-5 will swap workspaces 1 and 5
  [((modMask .|. controlMask, k), windows $ swapWithCurrent i)
      | (i, k) <- zip myWorkspaces [xK_1 ..]]
  -- ++
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))
  ]


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
main = do
  xmproc <- spawnPipe ("xmobar " ++ myXmobarrc)
  xmonad $ withUrgencyHook NoUrgencyHook $ docks $ defaults {
      logHook = dynamicLogWithPP . filterOutWsPP [scratchpadWorkspaceTag]  -- hides out namedscratchpad workspace
              $ xmobarPP
      {
          ppOutput = hPutStrLn xmproc
        , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "<" ">" -- Current workspace in xmobar
        -- , ppVisible = xmobarColor "#98be65" ""                -- Visible but not current workspace
        , ppHidden = xmobarColor xmobarEmptyWSColor "" . wrap "" "" . clickable -- Hidden & busy workspaces in xmobar
        , ppHiddenNoWindows = xmobarColor xmobarTitleColor "" -- Hidden workspaces (no windows)
        , ppUrgent = xmobarColor myFocusedBorderColor "" . wrap "!" "!" . clickable  -- Urgent workspace
        , ppSep = "<fc=#666666> <fn=2>] [</fn> </fc>" -- Separators in xmobar
        , ppWsSep = "<fc=#666666> <fn=2>|</fn> </fc>" --" | "
        , ppTitle = xmobarColor xmobarTitleColor "" . shorten 50 -- focused app title
      }
      , manageHook = manageDocks <+> insertPosition Above Newer <+> myManageHook
      , startupHook = myStartupHook
      -- adding DynamicPropertyChange hook to allow managing apps (i.e. open them a specific workspace) 
      -- which set the WM_CLASS with delay during opening 
      , handleEventHook =  dynamicPropertyChange "WM_CLASS" myManageHook
  }


------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,
    -- hooks, layouts
    layoutHook         = {-smartBorders $-} myLayout, 
    startupHook        = myStartupHook
}
