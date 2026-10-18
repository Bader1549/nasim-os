/*
 * Nasim OS default desktop layout (Plasma 6).
 * A bottom taskbar with the start menu and apps centred, like Windows 11.
 * Runs once per user at first login, or when the user applies the Nasim
 * Global Theme with "Use desktop layout from theme".
 */

// Desktop wallpaper
var allDesktops = desktopsForActivity(currentActivity());
for (var i = 0; i < allDesktops.length; i++) {
    var desk = allDesktops[i];
    desk.wallpaperPlugin = "org.kde.image";
    desk.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desk.writeConfig("Image", "file:///usr/share/wallpapers/Nasim/");
}

// One taskbar on every screen, like Windows.
for (var s = 0; s < screenCount; s++) {
    var panel = new Panel;
    panel.screen = s;
    panel.location = "bottom";
    panel.height = 48;
    panel.floating = false;
    panel.hiding = "none";
    panel.lengthMode = "fill";

    // [spacer] [start][apps] [spacer] [tray][clock][show desktop]
    // Two expanding spacers centre the start menu and apps on the whole panel.
    panel.addWidget("org.kde.plasma.panelspacer");

    var start = panel.addWidget("org.kde.plasma.kickoff");
    start.currentConfigGroup = ["General"];
    start.writeConfig("icon", "nasim-start");

    var tasks = panel.addWidget("org.kde.plasma.icontasks");
    tasks.currentConfigGroup = ["General"];
    // A non-empty list also stops Bazzite's bazzite-pins.js from adding its own pins.
    tasks.writeConfig("launchers", [
        "preferred://filemanager",
        "preferred://browser",
        "applications:code.desktop",
        "applications:steam.desktop",
        "applications:org.onlyoffice.desktopeditors.desktop"
    ]);

    panel.addWidget("org.kde.plasma.panelspacer");

    panel.addWidget("org.kde.plasma.systemtray");

    var clock = panel.addWidget("org.kde.plasma.digitalclock");
    clock.currentConfigGroup = ["Appearance"];
    clock.writeConfig("showDate", true);
    // Hijri (Umm al-Qura) dates in the calendar popup.
    clock.writeConfig("enabledCalendarPlugins", ["alternatecalendar"]);

    panel.addWidget("org.kde.plasma.showdesktop");
}
