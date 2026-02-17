{ config, ... }:

let
  # Stylix exposes base16 colors via config.lib.stylix.colors
  c = config.lib.stylix.colors;
in
{
  xdg.configFile."niri/config.kdl".text = ''
      input {
        keyboard {
          xkb {
          }
          numlock
        }
        touchpad {
          tap
          natural-scroll
        }
        mouse {
        }
        trackpoint {
        }
      }

      output "Virtual-1" {
        mode custom=true "3840x2560@60"
        scale 1.5
        transform "normal"
        position x=1280 y=0
      }

      layout {
        center-focused-column "never"
        always-center-single-column

        gaps 16
        struts {
          bottom -16
        }

        preset-column-widths {
          proportion 0.25
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
          proportion 0.75
        }

        default-column-width { proportion 0.5; }

        focus-ring {
          width 4
          active-color "#${c.base0D}"
          inactive-color "#${c.base03}"
        }

        border {
          off
          width 4
          active-color "#${c.base0D}"
          inactive-color "#${c.base03}"
          urgent-color "#${c.base08}"
        }

        shadow {
          softness 30
          spread 5
          offset x=0 y=5
          color "#0007"
        }

      }

    spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "DISPLAY" "XDG_CURRENT_DESKTOP" "XDG_SESSION_TYPE"
      spawn-at-startup "sh" "-c" "sleep 1s && swaybg -i ~/.wallpapers/wheat.png"
      spawn-at-startup "ironbar"

      hotkey-overlay {
        skip-at-startup
      }

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      animations {
      }

      window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        default-column-width {}
      }

      window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
      }

      binds {
        Mod+G hotkey-overlay-title="Open a Terminal: foot" { spawn "foot"; }
        Mod+P hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
        Mod+N hotkey-overlay-title="Toggle Notifications: swaync" { spawn "swaync-client" "-t" "-sw"; }
        Mod+Shift+N hotkey-overlay-title="Toggle Do Not Disturb: swaync" { spawn "swaync-client" "-d" "-sw"; }
        Super+Ctrl+Alt+Shift+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
        XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
        XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

        Mod+O repeat=false { toggle-overview; }

        Mod+Shift+W repeat=false { close-window; }

        Mod+H     { spawn "vim-niri-nav" "left"; }
        Mod+J     { spawn "vim-niri-nav" "down"; }
        Mod+K     { spawn "vim-niri-nav" "up"; }
        Mod+L     { spawn "vim-niri-nav" "right"; }

        Mod+Shift+H     { move-column-left; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+L     { move-column-right; }

        Mod+Page_Down      { focus-workspace-down; }
        Mod+Page_Up        { focus-workspace-up; }
        Mod+D              { focus-workspace-down; }
        Mod+U              { focus-workspace-up; }
        Mod+Shift+D         { move-column-to-workspace-down; }
        Mod+Shift+U         { move-column-to-workspace-up; }

        Super+1 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"1\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 1"; }
        Super+2 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"2\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 2"; }
        Super+3 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"3\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 3"; }
        Super+4 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"4\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 4"; }
        Super+5 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"5\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 5"; }
        Super+6 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"6\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 6"; }
        Super+7 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"7\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 7"; }
        Super+8 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"8\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 8"; }
        Super+9 { spawn-sh "[ \"$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')\" = \"9\" ] && niri msg action focus-workspace-previous || niri msg action focus-workspace 9"; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        Mod+Shift+Slash  { consume-or-expel-window-left; }
        Mod+Shift+1 { consume-or-expel-window-right; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+C { center-column; }
        Mod+Shift+C { center-visible-columns; }

        Mod+Minus { set-column-width "-8%"; }
        Mod+Shift+Equal { set-column-width "+8%"; }
        Mod+Shift+Minus { set-window-height "-8%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+T { toggle-column-tabbed-display; }

        Mod+Y { screenshot; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        Mod+Shift+E { quit; }
        Ctrl+Delete { quit; }

        Mod+Shift+P { power-off-monitors; }
      }
  '';
}
