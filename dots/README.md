<div align="center">

# ⚡ DOTFILES ⚡
**The nervous system of my workstation.**

[![Stow](https://img.shields.io/badge/Managed_by-GNU_Stow-blue?style=for-the-badge)](https://www.gnu.org/software/stow/)
[![Wayland](https://img.shields.io/badge/Display-Wayland-purple?style=for-the-badge)](https://wayland.freedesktop.org/)

</div>

---

## 🌌 Overview

This directory contains all my personal configurations, tightly bound and managed using **GNU Stow**. By keeping everything here, the workstation is entirely reproducible from a single Git repository. 

Say goodbye to manual symlinks and lost configurations!

### 📦 Managed Components

| Category | Components |
|---|---|
| **Window Manager** | `niri` |
| **Terminals** | `kitty`, `alacritty`, `ghostty` |
| **Shell & Core** | `fish`, `neovim` |
| **Desktop Shell** | `waybar`, `fuzzel`, `dunst` |
| **System Tools** | `btop`, `fastfetch`, `ranger` |
| **Theming & UI** | `gtk` (3.0/4.0) |
| **Media & Apps** | `mpv`, `zathura`, `noctalia`, `appimagelauncher` |

---

## 🛠️ Management Scripts

We use custom automation scripts (located in the repo root) to safely bridge these configurations with the live `$HOME` directory.

### `update-dots.sh` 📥
**Pulls the latest from GitHub and applies them locally.**
- Fetches upstream changes.
- Automatically runs `stow` to link configs into `~/.config/`.
- Handles conflicts elegantly.

### `sync-dots.sh` 📤
**Pulls live configurations from your system back into this repo.**
- Used when you tweak a config directly in `~/.config/` and want to save it.
- Replaces the repo version with the live version using `rsync`.
- Guides you through a clean `git commit` and push.

### `check-secrets.sh` 🔒
**Ensures no sensitive data leaks.**
- Scans this directory for hardcoded API keys, tokens, and passwords.
- Integrates with `gitleaks` (if installed) or falls back to regex.
- Can be installed as a git `pre-commit` hook!

---

## 🔗 Manual Stow Command

If you want to manually link a specific package (e.g. `niri`), run:
```bash
cd ..
stow --dir=dots --target=$HOME niri
```

To resolve conflicts (this will OVERWRITE the repo files with what's in `$HOME`):
```bash
stow --adopt --dir=dots --target=$HOME niri
```

---

<div align="center">
<i>"A clean config is a happy mind."</i>
</div>
