# sys-setup

> One command to restore my entire workstation across Arch, Ubuntu, Fedora, and macOS.

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Fedora](https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=white)](https://fedoraproject.org/)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)](https://apple.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Machine

- **Host**: MSI Thin GF63 12HW
- **CPU**: Intel Core i5-12500H (16 threads)
- **GPU**: Intel Arc A370M + Iris Xe
- **Display**: 1920×1080 @ 144Hz
- **OS**: Linux (Arch, Ubuntu, Fedora) / macOS

## Usage

### On a fresh install:

```bash
bash <(curl -sL https://raw.githubusercontent.com/as-repo1/sys-setup/main/install.sh)
```

### From a local clone:

```bash
git clone https://github.com/as-repo1/sys-setup.git ~/coding/sys-setup
cd ~/coding/sys-setup
bash install.sh
```

### Dry run (see what will happen without making changes):

```bash
bash install.sh --dry-run
```

---

## What It Does

The installer runs through **10 phases** interactively with a Nord-themed CRT terminal UI:

| Phase | Description                                                 |
| ----- | ----------------------------------------------------------- |
| 0     | Preflight checks (user, OS detection, package manager)      |
| 1     | Interactive profile selection (Typical / Complete / Custom) |
| 2     | Mirror ranking (Arch) / Package sources (Ubuntu/Fedora)     |
| 3     | Chaotic-AUR / RPM Fusion / Ubuntu Extras                    |
| 4     | Install AUR helpers, PPAs, or COPRs                         |
| 5     | Install packages (Native → Flatpak fallback)               |
| 6     | Enable systemd services                                     |
| 7     | Stow dotfiles                                               |
| 8     | Download & register AppImages                               |
| 9     | Post-install (git, docker, fish shell)                      |
| 10    | Summary + reboot prompt                                     |

### Installation Profiles

- **Typical** — Niri WM + Dev tools + Zen/Firefox/Chrome + core dotfiles *(2 keypresses)*
- **Complete** — Every package, utility, dotfile, and system option enabled
- **Custom** — Select exactly which categories to configure, skip the rest

---

## Structure

```
sys-setup/
├── install.sh              ← entry point
├── packages/
│   ├── pkglist-core.txt    ← always installed
│   ├── pkglist-aur.txt     ← AUR via yay
│   ├── pkglist-flatpak.txt ← flatpak apps
│   └── pkglist-optional.txt← optional groups
├── appimages/
│   └── appimages.csv       ← AppImage download manifest
├── system/
│   ├── pacman.conf         ← pacman config
│   └── services.txt        ← services to enable
├── dots/                   ← GNU Stow packages
│   ├── niri/
│   ├── waybar/
│   ├── fish/
│   ├── kitty/ ghostty/ alacritty/
│   ├── nvim/
│   ├── btop/ fastfetch/
│   ├── fuzzel/ dunst/
│   ├── gtk/
│   ├── zathura/ mpv/ ranger/
│   ├── noctalia/
│   └── appimagelauncher/
├── scripts/
│   ├── setup-chaotic-aur.sh
│   ├── setup-git.sh
│   ├── setup-docker.sh
│   ├── setup-android-sdk.sh
│   └── setup-appimages.sh
└── tests/
    ├── Dockerfile          ← Arch Linux test container
    └── test-in-docker.sh   ← build & run the container
```

---

## Dotfiles Management

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each subdirectory in `dots/` mirrors your `$HOME` structure.

### Apply manually:

```bash
stow --dir=dots --target=$HOME niri
stow --dir=dots --target=$HOME waybar
# etc.
```

### Resolve conflicts:

```bash
stow --adopt --dir=dots --target=$HOME <package>
```

---

## AppImages

Managed via [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).
All AppImages are downloaded to `~/Appimages/` and auto-registered.

| App                 | Source          |
| ------------------- | --------------- |
| AnythingLLM Desktop | GitHub Releases |
| LM Studio           | lmstudio.ai     |
| Pinokio             | GitHub Releases |
| iDescriptor         | GitHub Releases |
| AppImagePool        | GitHub Releases |

---

## Testing

A Docker-based test environment lets you safely test the installer against a clean Arch Linux container without touching your host system:

```bash
# Drop into an interactive shell inside the container
./tests/test-in-docker.sh

# Or run a dry-run directly
./tests/test-in-docker.sh --dry-run
```

---

## Notes

- **Secrets**: git credentials, browser sessions, and API keys are **never** committed.
- **Idempotent**: Safe to re-run — packages and stow links are skipped if already present.
- **Log**: Full install log saved to `~/sys-setup-install.log`
