{ config, pkgs, ... }:

let
  c = config.lib.stylix.colors;
in
{
  systemd.user.services.swaync.Service = {
    Environment = [
      "GSK_RENDERER=cairo"
    ];
  };

  services.swaync = {
    settings = {
      cssPriority = "application";
    };
    style = ''
      @define-color base-bg #${c.base01}cc;
      @define-color base-bg-hover #${c.base01}cc;
      @define-color base-fg #${c.base05};
      @define-color base-border #${c.base0D}77;

      .notification,
      .control-center {
        background: @base-bg;
        color: @base-fg;
        border: 2px solid;
      }
      .control-center {
        border-radius: 0;
        border-color: @base-bg-hover;
        border-top: none;
        border-bottom: none;
      }
      .notification {
        border-color: @base-border;
        padding: 5px 7px;
      }

      .notification-content,
      .summary,
      .body,
      .control-center * {
        color: @base-fg;
      }

      .notification-row,
      .notification-row:hover,
      .notification-row:focus,
      .notification-group,
      .notification-group-headers {
        background: transparent;
      }

      .notification:hover,
      .notification:focus,
      .notification:active,
      .notification-default-action:hover,
      .notification-default-action:focus,
      .notification-default-action:active {
        background: @base-bg-hover;
      }
    '';
  };
}
