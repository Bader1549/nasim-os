#!/usr/bin/env bash
# Removes Bazzite defaults that clash with Nasim OS. Runs once, at image build time.
set -euo pipefail

remove() {
  for f in "$@"; do
    if [[ -e "$f" ]]; then
      rm -f "$f"
      echo "nasim-cleanup: removed $f"
    else
      echo "nasim-cleanup: not present (ok): $f"
    fi
  done
}

# Startup apps: Steam in the background costs RAM, and the Bazzite Portal and
# announcement are English-only and offer update-track buttons that would move
# the user back to plain Bazzite.
remove \
  /etc/skel/.config/autostart/steam.desktop \
  /etc/skel/.config/autostart/bazzite-portal.desktop \
  /etc/xdg/autostart/bazzite-announcement.desktop

# Bazzite's once-per-user script that pins Steam, Lutris, Bazaar etc. to the taskbar.
# Our layout sets its own pins; this is a second safety net.
remove /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js

# Bazzite also appended those pins to the "Default Panel" template that is used
# when someone adds a new panel. Cut them off again.
template=/usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js
if [[ -f "$template" ]] && grep -q '^const allPanels = panels();$' "$template"; then
  sed -i '/^const allPanels = panels();$/,$d' "$template"
  echo "nasim-cleanup: removed Bazzite pins from $template"
else
  echo "nasim-cleanup: no Bazzite pins in $template (ok)"
fi
