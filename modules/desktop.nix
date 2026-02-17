{ pkgs, ... }:
{
	programs.niri.enable = true;
	services.dbus.enable = true;
	services.upower.enable = true;

	environment.systemPackages = [
		pkgs.xwayland-satellite
	];

	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
		config.common.default = [ "gtk" ];
	};

	programs.dconf = {
		enable = true;
		profiles.user.databases = [{
			settings."org/gnome/interface" = {
				color-scheme = "prefer-dark";
			};
		}];
	};

	services.greetd = {
		enable = true;
		settings = {
			default_session = {
				command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri";
				user = "greeter";
			};
		};
	};

	environment.variables = {
		NIXOS_OZONE_WL = "1";
		XDG_SESSION_TYPE = "wayland";
	};
}
