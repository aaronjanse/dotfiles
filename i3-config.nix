nixpkgs:
let
  workspaceIndicies = [ 1 2 3 4 5 6 7 8 9 10 ];
  mappings = mod: ''
    ${nixpkgs.lib.concatMapStrings
    (i: "bindsym ${mod}+${
        builtins.toString (nixpkgs.lib.mod i 10)
    } workspace ${builtins.toString i}\n")
    workspaceIndicies}
    ${nixpkgs.lib.concatMapStrings
    (i: "bindsym ${mod}+Shift+${
        builtins.toString (nixpkgs.lib.mod i 10)
    } move container to workspace ${builtins.toString i}\n")
    workspaceIndicies}

    bindsym ${mod}+Shift+q kill

    bindsym ${mod}+Up focus up
    bindsym ${mod}+Down focus down
    bindsym ${mod}+Left focus left
    bindsym ${mod}+Right focus right

    bindsym ${mod}+Shift+Up move up
    bindsym ${mod}+Shift+Down move down
    bindsym ${mod}+Shift+Left move left
    bindsym ${mod}+Shift+Right move right

    bindsym ${mod}+bracketleft focus left
    bindsym ${mod}+bracketright focus right
    bindsym ${mod}+Shift+bracketleft move left
    bindsym ${mod}+Shift+bracketright move right

    bindsym ${mod}+Return exec ${nixpkgs.alacritty}/bin/alacritty

    ${if true then "" else "bindsym ${mod}+Shift+X exec ${../bin/clear-clipboard.sh}"}

    bindsym ${mod}+d exec ${nixpkgs.rofi}/bin/rofi -show run
    bindsym ${mod}+Shift+d exec ${nixpkgs.rofi}/bin/rofi -modi 'drun' -show drun

    bindsyn ${mod}+Shift+s exec ${nixpkgs.flameshot}/bin/flameshot gui

    bindsym ${mod}+equal workspace next
    bindsym ${mod}+minus workspace prev
    bindsym ${mod}+Tab workspace back_and_forth

    bindsym ${mod}+Shift+r restart

    bindsym ${mod}+n gaps inner all set 0
    bindsym ${mod}+g gaps inner all set 10

    bindsym ${mod}+r mode resizeAlt

    bindsym ${mod}+Shift+space floating toggle
    bindsym ${mod}+f fullscreen toggle
    bindsym ${mod}+s layout stacking
    bindsym ${mod}+w layout tabbed
    bindsym ${mod}+e layout toggle split
    bindsym ${mod}+u split v
    bindsym ${mod}+y split h
  '';

  resizing = ''
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Right resize grow width 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
  '';
in
nixpkgs.writeText "i3-config" ''
  font pango:Roboto Mono 8
  floating_modifier Shift
  new_window pixel 1
  new_float pixel 2
  hide_edge_borders none
  force_focus_wrapping no
  focus_follows_mouse yes
  focus_on_window_activation smart
  mouse_warping output
  workspace_layout default
  workspace_auto_back_and_forth no

  client.focused #61afef #000000 #ffffff #61afef #61afef
  client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
  client.unfocused #f8f8f2 #000000 #ffffff #f8f8f2 #f8f8f2
  client.urgent #2f343a #900000 #ffffff #900000 #900000
  client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
  client.background #ffffff

  bindsym F1 exec ${nixpkgs.light}/bin/light -U 5
  bindsym F2 exec ${nixpkgs.light}/bin/light -A 5

  bindsym Shift+F1 exec light -S 0
  bindsym XF86AudioLowerVolume exec amixer set Master 5%-
  bindsym XF86AudioMute exec amixer set Master 0%
  bindsym XF86AudioNext exec ${nixpkgs.playerctl}/bin/playerctl next
  bindsym XF86AudioPause exec ${nixpkgs.playerctl}/bin/playerctl pause
  bindsym XF86AudioPrev exec ${nixpkgs.playerctl}/bin/playerctl previous
  bindsym XF86AudioRaiseVolume exec amixer set Master 5%+
  bindsym XF86MonBrightnessDown exec light -U 5
  bindsym XF86MonBrightnessUp exec light -A 5


  bindsym Mod4+Shift+M mode defaultWin
  mode "defaultWin" {
      bindsym Mod1+Shift+M mode default
      ${mappings "Mod4"}
  }

  ${mappings "Mod1"}

  mode "resizeAlt" {
      ${resizing}
      bindsym Escape mode default
      bindsym Return mode default
  }

  mode "resizeWin" {
      ${resizing}
      bindsym Escape mode defaultWin
      bindsym Return mode defaultWin
  }

  smart_gaps on
  smart_borders on
''
