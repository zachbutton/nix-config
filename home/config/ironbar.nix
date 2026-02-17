{ config, ... }:

let
  c = config.lib.stylix.colors;
  sans = config.stylix.fonts.sansSerif.name;
  mono = config.stylix.fonts.monospace.name;
  iconTheme =
    if config.stylix.polarity == "light" then config.stylix.icons.light else config.stylix.icons.dark;
in
{
  xdg.configFile."ironbar/config.json".text = builtins.toJSON {
    icon_theme = iconTheme;
    position = "top";

    start = [
      {
        type = "workspaces";
      }
      {
        type = "launcher";
        icon_size = 20;
        truncate = {
          mode = "end";
          max_length = 30;
        };
      }
    ];

    center = [
      {
        type = "clock";
        format = "%m/%d/%Y %H:%M";
      }
    ];

    end = [
      {
        type = "battery";
        show_if = "ls /sys/class/power_supply/ | grep --quiet '^BAT'";
        icon_size = 18;
        profiles = {
          warning = 20;
          critical = {
            when = {
              percent = 10;
              charging = false;
            };
          };
        };
      }
      {
        type = "sys_info";
        format = [
          "{cpu_percent}% "
          "{memory_percent}% "
        ];
        interval = {
          cpu = 1;
        };
      }
      {
        type = "clipboard";
        max_items = 5;
        truncate = {
          mode = "end";
          length = 30;
        };
      }
      {
        type = "music";
        player_type = "mpd";
      }
      {
        type = "volume";
      }
      {
        type = "tray";
      }
      {
        type = "notifications";
      }
      {
        type = "custom";
        name = "power-menu";
        class = "power-menu";
        bar = [
          {
            type = "button";
            name = "power-btn";
            label = "";
            on_click = "popup:toggle";
          }
        ];
        popup = [
          {
            type = "box";
            orientation = "vertical";
            widgets = [
              {
                type = "label";
                name = "header";
                label = "Power menu";
              }
              {
                type = "box";
                name = "buttons";
                widgets = [
                  {
                    type = "button";
                    class = "power-btn";
                    label = "<span>󰐥</span>";
                    on_click = "!shutdown now";
                  }
                  {
                    type = "button";
                    class = "power-btn";
                    label = "<span>󰜉</span>";
                    on_click = "!reboot";
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  };

  xdg.configFile."ironbar/style.css".text = ''
    :root {
      --color-transparent: transparent;

      --color-dark-primary: #${c.base0D}cc;
      --color-dark-secondary: #${c.base01}cc;

      --color-border-dark: #${c.base03}66;
      --color-border-light: #${c.base03}44;

      --color-white: #${c.base05};
      --color-active: #${c.base0D}cc;
      --color-active-soft: #${c.base0D}66;
      --color-active-strong: #${c.base0D}bb;
      --color-urgent: #${c.base08}cc;
      --color-accent-strong: #${c.base0E}aa;

      --color-battery-warning: #${c.base0A};
      --color-battery-critical: #${c.base08};
      --color-battery-charging: #${c.base0B};

      --gradient: linear-gradient(90deg, #${c.base0D}2e 35%, #${c.base0E}2e 100%);

      --margin-lg: 1em;
      --margin-sm: 0.5em;
      --margin-xs: 0.25em;

      --size-xxl: 2.6em;
      --size-xl: 2.2em;
      --size-lg: 1.5em;
      --size-md: 16px;
    }

    * {
      font-family: "${sans}", "${mono}", sans-serif;
      font-size: var(--size-md);
      color: var(--color-white);
      border-radius: 0;
      border: none;
      box-shadow: none;
    }

    #bar,
    #bar * {
      color: var(--color-white);
    }

    popover, popover contents {
      border-radius: 12px;
      padding: 0;
    }

    window, popover {
      background-color: var(--color-transparent);
    }

    box, button, label, calendar {
      background-color: var(--color-transparent);
    }

    #bar, popover contents {
      background-color: var(--color-dark-secondary);
    }

    scale.horizontal highlight {
      background: linear-gradient(90deg, var(--color-active-strong) 35%, var(--color-accent-strong) 100%);
    }

    scale.vertical highlight {
      background: linear-gradient(0deg, var(--color-active-strong) 35%, var(--color-accent-strong) 100%);
    }

    slider {
      border-radius: 100%;
    }

    button {
      padding-left: var(--margin-sm);
      padding-right: var(--margin-sm);
    }

    button:hover, button:active,
    dropdown popover row:hover,
    dropdown popover row:focus,
    dropdown popover row:selected {
      background-color: var(--color-dark-secondary);
    }

    radio {
      margin-right: var(--margin-sm);
    }

    #end > * + * {
      margin-left: var(--margin-sm);
    }

    .popup {
      padding: var(--margin-lg);
    }

    .clock {
      font-weight: bold;
    }

    .popup-clock .calendar-clock {
      font-size: var(--size-xl);
      margin-bottom: var(--margin-xs);
    }

    .popup-clock .calendar .today {
      background-color: var(--color-active-soft);
      border-radius: 0.25em;
    }

    .popup-clipboard .item {
      padding: var(--margin-xs);
    }

    .popup-clipboard .item + .item {
      border-top: 1px solid var(--color-border-light);
    }

    .launcher .item + .item {
      margin-left: 4px;
    }

    .launcher .item.open {
      box-shadow: inset 0 -1px var(--color-white);
    }

    .launcher .item.focused {
      box-shadow: inset 0 -1px var(--color-active);
    }

    .launcher .item.urgent {
      box-shadow: inset 0 -1px var(--color-urgent);
    }

    .popup-launcher {
      padding: var(--margin-sm);
    }

    .popup-launcher .popup-item {
      padding: var(--margin-lg);
      border-radius: 10px;
    }

    .popup-launcher .popup-item label {
      margin-top: var(--margin-sm);
    }

    .menu label {
      padding: 0 var(--margin-sm);
    }

    .popup-menu .sub-menu {
      border-left: 1px solid var(--color-border-light);
      padding-left: var(--margin-sm);
    }

    .popup-menu .category,
    .popup-menu .application {
      padding: var(--margin-xs);
    }

    .popup-menu .category.open {
      background-color: var(--color-dark-secondary);
    }

    .popup-music .album-art {
      margin-right: var(--margin-lg);
      border-radius: 5px;
    }

    .popup-music .icon-box {
      margin-right: var(--margin-sm);
    }

    .popup-music .title .icon,
    .popup-music .title .label {
      font-size: var(--size-lg);
    }

    .popup-music .artist .label,
    .popup-music .album .label {
      margin-left: 6px;
    }

    .popup-music .volume .icon {
      margin-right: 3px;
    }

    .notifications .count {
      font-size: 0.8em;
      padding: 0.18em;
    }

    .sysinfo > .item + .item {
      margin-left: var(--margin-sm);
    }

    .tray popover contents {
      padding: var(--margin-lg);
    }

    .volume .source {
      margin-left: var(--margin-sm);
    }

    .popup-volume .device-box {
      padding-right: var(--margin-lg);
      margin-right: var(--margin-lg);
      border-right: 1px solid var(--color-border-light);
    }

    .workspaces .item.visible {
      box-shadow: inset 0 -1px var(--color-white);
    }

    .workspaces .item.focused {
      box-shadow: inset 0 -1px var(--color-active);
      background-color: var(--color-active-soft);
    }

    .workspaces .item.active {
      box-shadow: inset 0 -1px var(--color-active);
      background-color: var(--color-active-soft);
    }

    .workspaces .item.urgent {
      background-color: var(--color-urgent);
    }

    .battery.warning {
      color: var(--color-battery-warning);
    }

    .battery.critical {
      color: var(--color-battery-critical);
    }

    .battery.charging {
      color: var(--color-battery-charging);
    }

    .battery .icon {
      color: inherit;
      -gtk-icon-style: symbolic;
      -gtk-icon-palette: error var(--color-battery-critical), warning var(--color-battery-warning), success var(--color-battery-charging);
    }

    .popup-power-menu #header {
      font-size: var(--size-lg);
      margin-bottom: 0.6em;
    }

    .popup-power-menu .power-btn {
      border: 1px solid var(--color-border-dark);
      border-radius: 10px;
      padding: 0 1.2em;
    }

    .popup-power-menu .power-btn label {
      font-size: var(--size-xxl);
    }

    .popup-power-menu #buttons > * + * {
      margin-left: 1.3em;
    }
  '';
}
