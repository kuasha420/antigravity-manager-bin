# antigravity-manager-bin

AUR package build for [antigravity-manager-bin](https://aur.archlinux.org/packages/antigravity-manager-bin) — a pre-built binary package of [AntigravityManager](https://github.com/Draculabo/AntigravityManager), a professional multi-account manager for Google Gemini & Claude AI.

## Install

### Via an AUR helper

```sh
paru -S antigravity-manager-bin
# or
yay -S antigravity-manager-bin
```

### Manually

```sh
git clone https://aur.archlinux.org/antigravity-manager-bin.git
cd antigravity-manager-bin
makepkg -si
```

## Version bumping

`bump-version.sh` automates fetching the latest upstream release, updating checksums, regenerating `.SRCINFO`, and committing:

```sh
# Auto-bump to latest upstream release
./bump-version.sh

# Bump to a specific version
./bump-version.sh 0.11.0

# Check if an update is available (exit 0 = yes, exit 1 = already up-to-date)
./bump-version.sh --check
```

**Dependencies:** `curl`, `python3` (stdlib), `makepkg`, `git`

## Package details

| Field         | Value                                                                                 |
| ------------- | ------------------------------------------------------------------------------------- |
| Upstream      | [Draculabo/AntigravityManager](https://github.com/Draculabo/AntigravityManager)       |
| AUR page      | [antigravity-manager-bin](https://aur.archlinux.org/packages/antigravity-manager-bin) |
| Architectures | `x86_64`, `aarch64`                                                                   |
| Source format | Upstream RPM, extracted via `bsdtar`                                                  |
| License       | CC-BY-NC-SA-4.0                                                                       |
