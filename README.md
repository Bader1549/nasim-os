# Nasim OS · نظام نسيم

[![bluebuild build badge](https://github.com/Bader1549/nasim-os/actions/workflows/build.yml/badge.svg)](https://github.com/Bader1549/nasim-os/actions/workflows/build.yml)

نظام لينكس خفيف وشكله قريب من ويندوز، للبرمجة والألعاب والشغل المكتبي. مبني على [Bazzite](https://bazzite.gg).

A light, Windows-like Linux for coding, gaming and office work. Built with [BlueBuild](https://blue-build.org) on top of [Bazzite](https://bazzite.gg). Nasim OS is a personal project and is not affiliated with Bazzite, Universal Blue or Microsoft.

## What you get · وش فيه

| | |
|---|---|
| Desktop | KDE Plasma with a Windows-11-style centred taskbar, Fluent icons, Hijri (Umm al-Qura) calendar in the clock |
| Coding | Visual Studio Code, Podman, Distrobox, Homebrew |
| Gaming | Steam, Lutris, Heroic (Epic / GOG / Amazon), Greenlight (Xbox Cloud Gaming), Proton tools |
| Office | OnlyOffice (opens Word, Excel and PowerPoint files), Okular (PDF) |
| Internet | Google Chrome, Discord, OneDrive as a normal folder (onedriver) |
| Windows programs | Double-click a `.exe` to open it with Bottles |
| Arabic | Arabic UI available, Arabic fonts (Noto, Amiri, Cairo, Tajawal, KACST), Alt+Shift switches English/Arabic keyboard |

Some apps (Chrome, OnlyOffice, Heroic, Bottles, Discord and others) download automatically from Flathub on first boot, so the first start needs internet.

## Images · النسخ

| Image | For |
|---|---|
| `ghcr.io/bader1549/nasim-os` | AMD and Intel graphics (most PCs and laptops) |
| `ghcr.io/bader1549/nasim-os-nvidia` | NVIDIA GTX 16xx, RTX 20 series and newer |

Requirements (same as Bazzite): 64-bit x86 PC with UEFI, 8 GB RAM recommended, 50 GB free on an SSD. TPM is not needed.

## Known limits · حدود معروفة

- Games with kernel anti-cheat (Valorant, Fortnite and similar) do not run on Linux.
- There is no Xbox app on Linux. Xbox Cloud Gaming runs through Greenlight or the browser, where Microsoft offers it in your region.
- Not every Windows program works through Bottles.

## Switch an existing Bazzite / Fedora Atomic install

```bash
sudo bootc switch ghcr.io/bader1549/nasim-os:latest && sudo systemctl reboot
# after the reboot, switch to the signed image:
sudo bootc switch --enforce-container-sigpolicy ghcr.io/bader1549/nasim-os:latest && sudo systemctl reboot
```

Use `nasim-os-nvidia` instead of `nasim-os` on NVIDIA PCs.

Coming from Bazzite, your account still has Bazzite's startup apps. To stop Steam and the Bazzite Portal opening at login (optional):

```bash
rm -f ~/.config/autostart/steam.desktop ~/.config/autostart/bazzite-portal.desktop
```

## Secure Boot

Nasim OS uses Bazzite's signed kernel, so with Secure Boot on, the Universal Blue key must be enrolled.

- Coming from Bazzite or another Universal Blue image: it is normally enrolled already. If not, run `ujust enroll-secure-boot-key`.
- Coming from Fedora Atomic: enroll it **before** switching:

  ```bash
  curl -LO https://github.com/ublue-os/bazzite/raw/main/secure_boot.der
  sudo mokutil --timeout -1
  sudo mokutil --import secure_boot.der
  ```

  Reboot, choose "Enroll MOK" and type the password `universalblue`. The key screen uses an English (QWERTY) keyboard.

## Verification

Images are signed with [cosign](https://github.com/sigstore/cosign):

```bash
cosign verify --key cosign.pub ghcr.io/bader1549/nasim-os
```
