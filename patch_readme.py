with open("README.md", "r") as f:
    content = f.read()

content = content.replace(
    "> One command to restore my entire Arch/EndeavourOS workstation.\n\n[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)\n[![EndeavourOS](https://img.shields.io/badge/EndeavourOS-7B2FBE?logo=linux&logoColor=white)](https://endeavouros.com/)",
    "> One command to restore my entire workstation across Arch, Ubuntu, Fedora, and macOS.\n\n[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)\n[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)\n[![Fedora](https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=white)](https://fedoraproject.org/)\n[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)](https://apple.com/)"
)

content = content.replace(
    "- **OS**: EndeavourOS / Arch Linux",
    "- **OS**: Linux (Arch, Ubuntu, Fedora) / macOS"
)

content = content.replace(
    "### On a fresh Arch install:\n",
    "### On a fresh install:\n"
)

content = content.replace(
    "| 0     | Preflight checks (user, internet, arch, sudo) |",
    "| 0     | Preflight checks (user, OS detection, package manager) |"
)

content = content.replace(
    "| 2     | Mirror ranking with reflector                 |",
    "| 2     | Mirror ranking (Arch) / Package sources (Ubuntu/Fedora) |"
)

content = content.replace(
    "| 3     | Chaotic-AUR setup (optional)                  |",
    "| 3     | Chaotic-AUR / RPM Fusion / Ubuntu Extras      |"
)

content = content.replace(
    "| 4     | Install yay (AUR helper)                      |",
    "| 4     | Install AUR helpers, PPAs, or COPRs           |"
)

content = content.replace(
    "| 5     | Install packages (core → AUR → flatpak)     |",
    "| 5     | Install packages (Native → Flatpak fallback)  |"
)

with open("README.md", "w") as f:
    f.write(content)
