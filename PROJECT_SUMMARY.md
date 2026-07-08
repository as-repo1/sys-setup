# Project Summary: sys-setup

This document describes what this project is, what has been implemented so far, and what the most recent change introduced in detail.

## 1. Project overview

This repository is a workstation bootstrap and dotfiles provisioning project for Linux and macOS. Its purpose is to give a user a repeatable way to set up a complete development and desktop environment from scratch with a single entry point.

The project is centered around a shell-based installer that can:

- detect the current operating system,
- choose the appropriate package manager,
- install the required tools and apps,
- configure shell/dotfile setup,
- enable services,
- manage AppImages,
- and provide a guided interactive experience.

In short, this project is designed to make machine setup fast, consistent, and reproducible.

---

## 2. What this project does

### 2.1 Main purpose

The goal of the project is to automate the process of rebuilding a workstation environment. Instead of manually installing tools, configuring shell settings, enabling services, and arranging dotfiles one by one, the user can run a single installer and let the project handle most of the setup.

This is especially useful for:

- fresh OS installations,
- switching machines,
- restoring a previously configured environment,
- and keeping a personal setup documented and reproducible.

### 2.2 Core capabilities

The repository currently provides the following capabilities:

1. Cross-platform installer entry point
   - The main installer is implemented in [install.sh](install.sh).
   - It supports Arch, Ubuntu, Fedora, and macOS workflows.

2. Interactive setup experience
   - The installer uses a terminal-based UI with the help of Gum.
   - It presents phases, prompts, and confirmation dialogs in a guided flow.

3. OS-aware package management
   - The installer detects the platform and routes package installation to the right package manager.
   - This covers pacman, apt, dnf, and Homebrew-style workflows.

4. Package mapping system
   - The package mapping logic is handled in [packages/pkg-map.sh](packages/pkg-map.sh).
   - It translates canonical package names into distro-specific package names depending on the detected OS.

5. Dotfiles management
   - The repository contains a structured dotfiles tree under [dots](dots).
   - Dotfiles are intended to be installed with GNU Stow, making configuration management modular and repeatable.

6. System service setup
   - The installer can enable system services through configuration files such as [system/services.txt](system/services.txt).

7. AppImage support
   - The project includes AppImage-related configuration and download logic.
   - This helps users install desktop app bundles in a more portable way.

8. Testing workflow
   - A Docker-based test pipeline is included in [tests/test-in-docker.sh](tests/test-in-docker.sh).
   - This makes it possible to validate the installer in a controlled environment without touching the host machine.

---

## 3. Repository structure and responsibilities

### 3.1 Entry point

- [install.sh](install.sh)
  - The main bootstrap script.
  - It detects the OS, checks prerequisites, installs dependencies, and runs the setup flow.

### 3.2 Package definitions

- [packages/pkg-map.sh](packages/pkg-map.sh)
  - Centralized mapping of package names by platform.
  - Used by the installer to choose the correct package name for each distribution.

- [packages/pkglist-core.txt](packages/pkglist-core.txt)
- [packages/pkglist-aur.txt](packages/pkglist-aur.txt)
- [packages/pkglist-flatpak.txt](packages/pkglist-flatpak.txt)
  - These files define package groups that the installer can use during setup.

### 3.3 Dotfiles and configuration

- [dots](dots)
  - Contains the actual configuration files for terminal tools, editors, desktop environments, and utilities.
  - Each subdirectory acts like a package that can be stowed into the home directory.

### 3.4 Helper scripts

- [scripts/setup-git.sh](scripts/setup-git.sh)
  - Configures git with user identity and defaults.

- [scripts/setup-docker.sh](scripts/setup-docker.sh)
  - Helps configure Docker support.

- [scripts/setup-android-sdk.sh](scripts/setup-android-sdk.sh)
  - Assists with Android SDK setup.

### 3.5 System-level configuration

- [system/pacman.conf](system/pacman.conf)
  - Arch-specific pacman configuration.

- [system/services.txt](system/services.txt)
  - Service names that should be enabled during setup.

### 3.6 Tests

- [tests/Dockerfile](tests/Dockerfile)
- [tests/test-in-docker.sh](tests/test-in-docker.sh)
  - Provide a reproducible Docker environment to test the installer safely.

---

## 4. Installation flow

The installer is organized into phases. The current documentation describes roughly 10 phases:

1. Preflight checks
   - Validate the user context, OS, package manager availability, and internet access.

2. Profile selection
   - Let the user choose between a typical setup, a complete setup, or a custom setup.

3. Repository/source setup
   - Configure package sources or extra repositories depending on the platform.

4. Additional repositories
   - Enable Chaotic-AUR, RPM Fusion, PPAs, or other package sources as needed.

5. Package installation
   - Install base packages and utilities through the appropriate package manager.

6. Service activation
   - Enable required services for the system environment.

7. Dotfiles installation
   - Link configuration files into the home directory using Stow.

8. AppImage registration
   - Fetch and register AppImages for desktop applications.

9. Post-install configuration
   - Configure git, shell tools, Docker, or other post-setup tasks.

10. Summary and reboot prompt
   - Present the user with a final summary and give them the option to reboot.

---

## 5. Design philosophy

The project is guided by a few clear principles:

- Automation: reduce manual setup time.
- Portability: work across multiple operating systems.
- Repeatability: make setup reproducible and idempotent.
- Safety: support dry-run mode and testing environments.
- Personalization: allow typical, complete, and custom profiles.

This makes the project more than just a one-off shell script. It is a small infrastructure tool for personal environment maintenance.

---

## 6. What we have done in this project so far

Looking at the repository as it stands, the project already includes a substantial amount of work:

### 6.1 Built a universal installer

The main installer is no longer limited to a single Linux distribution. It now has a general structure that can detect and adapt to different environments.

### 6.2 Added platform-aware package handling

The package mapping layer allows the installer to choose the correct package names per operating system, rather than assuming a single package naming convention.

### 6.3 Organized configuration into reusable dotfiles packages

The dotfiles tree is structured for modular deployment, which makes the setup highly maintainable.

### 6.4 Added testing support

A Docker-based validation workflow helps ensure that the installer can be tested safely before being run on a real machine.

### 6.5 Documented the workflow clearly

The repository includes a detailed README that explains the intended usage, structure, setup approach, and testing strategy.

---

## 7. The last change in detail

The most recent change in the repository is the expansion of the setup system to support multi-platform workflows across Arch, Ubuntu, Fedora, and macOS.

### 7.1 What changed conceptually

Previously, the project was centered more narrowly around an Arch or EndeavourOS oriented setup. The most recent update broadened the scope so the same installer can work across multiple operating systems.

### 7.2 What this change introduced

The key changes in the latest update include:

- broader platform support in the documentation and project messaging,
- improved OS detection logic,
- package-manager abstraction for different systems,
- more generic and flexible installer behavior,
- and a clearer positioning of the tool as a universal workstation bootstrap solution.

### 7.3 Why this change matters

This is a major improvement because it turns the project from a distribution-specific setup script into a cross-platform setup toolkit. That makes it more useful for users who work across different operating systems or want a single workflow that can be reused in multiple environments.

### 7.4 Practical effect of the change

After this update, the project can:

- recognize whether it is running on Arch, Ubuntu, Fedora, or macOS,
- choose the right installation method for that platform,
- and present the setup process as a unified experience instead of a distro-specific one.

In other words, the latest change improved the project’s flexibility and made it substantially more general-purpose.

---

## 8. Summary

This project is a personal workstation setup automation tool. It combines:

- an installer,
- package management abstraction,
- dotfile deployment,
- AppImage support,
- service configuration,
- and testing workflows.

The most recent change made the project far more useful by extending it from a more limited setup script into a broader multi-platform bootstrap system.

That change is the biggest milestone in the current state of the repository because it expands the target audience and makes the project much more adaptable.
