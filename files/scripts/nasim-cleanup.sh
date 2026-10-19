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

# Nothing may switch a Nasim PC to another system (plain Bazzite, its testing
# track, or its other images). Remove the Portal's "update track" buttons...
yafti=/usr/share/yafti/yafti.yml
if [[ -f "$yafti" ]]; then
  sed -i '/id: "rebase-bazzite-stable"/,/id: "reset-bazzite"/{/id: "reset-bazzite"/!d}' "$yafti"
  if grep -q 'rebase-bazzite' "$yafti"; then echo "nasim-cleanup: FAILED to remove rebase buttons" >&2; exit 1; fi
  echo "nasim-cleanup: removed Portal rebase buttons"
fi
# ...and replace Bazzite's rebase helper (brh / bruh) with one that can only roll
# back to the previous Nasim version.
for f in /usr/bin/bazzite-rollback-helper /usr/bin/brh /usr/bin/bruh; do
  [[ -e "$f" || -L "$f" ]] || continue
  rm -f "$f"
  cat > "$f" <<'EOF'
#!/usr/bin/env bash
# Nasim OS: switching to other systems is disabled. Only rolling back works.
if [[ "${1:-}" == "rollback" ]]; then exec pkexec rpm-ostree rollback; fi
echo "Nasim OS: switching to another system is disabled. Use '$(basename "$0") rollback' to go back to the previous Nasim version." >&2
echo "نسيم: التبديل لنظام ثاني موقّف. للرجوع للنسخة السابقة من نسيم: $(basename "$0") rollback" >&2
exit 1
EOF
  chmod 0755 "$f"
  echo "nasim-cleanup: replaced $f with a rollback-only helper"
done

# Bazzite also appended those pins to the "Default Panel" template that is used
# when someone adds a new panel. Cut them off again.
template=/usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js
if [[ -f "$template" ]] && grep -q '^const allPanels = panels();$' "$template"; then
  sed -i '/^const allPanels = panels();$/,$d' "$template"
  echo "nasim-cleanup: removed Bazzite pins from $template"
else
  echo "nasim-cleanup: no Bazzite pins in $template (ok)"
fi
