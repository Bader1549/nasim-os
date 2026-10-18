#!/usr/bin/env bash
# Nasim OS names and logos. Runs once, at image build time.
set -euo pipefail

# os-release: change only the fields people see. ID, ID_LIKE, VERSION_ID,
# VARIANT_ID and IMAGE_ID stay as Bazzite set them, because Bazzite's tools,
# the bootloader setup and BlueBuild all read them.
sed -i \
  -e 's|^NAME=.*|NAME="Nasim OS"|' \
  -e 's|^PRETTY_NAME=.*|PRETTY_NAME="Nasim OS"|' \
  -e 's|^HOME_URL=.*|HOME_URL="https://github.com/Bader1549/nasim-os"|' \
  -e 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/Bader1549/nasim-os"|' \
  -e 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/Bader1549/nasim-os/issues"|' \
  -e 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/Bader1549/nasim-os/issues"|' \
  -e 's|^LOGO=.*|LOGO=nasim-logo|' \
  -e 's|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="nasim"|' \
  -e 's|^BOOTLOADER_NAME="Bazzite|BOOTLOADER_NAME="Nasim OS|' \
  /usr/lib/os-release
echo "nasim-branding: os-release is now:"
grep -E '^(NAME|PRETTY_NAME|ID|ID_LIKE|VERSION_ID|LOGO|DEFAULT_HOSTNAME)=' /usr/lib/os-release

# Point Bazzite's image metadata at Nasim. Its rollback helper and the Portal's
# "update track" buttons build ghcr.io/ublue-os/<image-name>; with Bazzite's name
# they would silently switch the PC to plain Bazzite and reboot. With Nasim's
# name that rebase fails safely instead. Bazzite's other scripts only check
# whether the name contains "deck", "dx" or "nvidia", which still matches.
info=/usr/share/ublue-os/image-info.json
if [[ -f "$info" ]]; then
  base_name=$(jq -r '."image-name" // ""' "$info")
  name="${IMAGE_NAME:-}"
  name="${name##*/}"
  if [[ -z "$name" ]]; then
    case "$base_name" in
      *nvidia*) name=nasim-os-nvidia ;;
      *)        name=nasim-os ;;
    esac
  fi
  tmp=$(mktemp)
  jq --arg n "$name" \
     --arg r "ostree-image-signed:docker://ghcr.io/bader1549/$name" \
     '."image-name" = $n | ."image-vendor" = "bader1549" | ."image-ref" = $r' \
     "$info" > "$tmp"
  install -m 0644 "$tmp" "$info"
  rm -f "$tmp"
  echo "nasim-branding: image-info.json image-name $base_name -> $name"
fi

# Logo for the About page.
install -Dm644 /usr/share/icons/hicolor/scalable/apps/nasim-logo.svg /usr/share/pixmaps/nasim-logo.svg

# Fluent's start-here icons are four blue squares that look like the Windows
# logo. Point them at our own logo instead.
find /usr/share/icons -path '*Fluent*' -name 'start-here*.svg' \
  -exec ln -sf /usr/share/icons/hicolor/scalable/apps/nasim-start.svg {} \;

# Refresh icon caches so apps find the new icons.
gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
for t in /usr/share/icons/Fluent /usr/share/icons/Fluent-dark /usr/share/icons/Fluent-light; do
  if [[ -d "$t" ]]; then
    gtk-update-icon-cache -f -t "$t" || true
  fi
done
