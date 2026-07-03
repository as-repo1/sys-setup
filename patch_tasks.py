with open("/home/chaos/.gemini/antigravity-ide/brain/5a5c5fc8-748c-4fb0-a38f-4a10af1a8aff/task.md", "r") as f:
    content = f.read()

content = content.replace("[ ] Fix `pkglist-core.txt` — XWayland, remove dupes", "[x] Fix `pkglist-core.txt` — XWayland, remove dupes")
content = content.replace("[ ] Fix `services.txt` — remove conditional services", "[x] Fix `services.txt` — remove conditional services")
content = content.replace("[ ] Fix `pacman.conf` — remove hardcoded chaotic-aur", "[x] Fix `pacman.conf` — remove hardcoded chaotic-aur")
content = content.replace("[ ] Update `README.md` — multi-platform docs", "[x] Update `README.md` — multi-platform docs")

with open("/home/chaos/.gemini/antigravity-ide/brain/5a5c5fc8-748c-4fb0-a38f-4a10af1a8aff/task.md", "w") as f:
    f.write(content)
