#!/usr/bin/env bash
# bump-version.sh — Automated version bump for antigravity-manager-bin AUR package
#
# Usage:
#   ./bump-version.sh           # auto-detects latest upstream version
#   ./bump-version.sh 0.11.0    # bump to a specific version
#   ./bump-version.sh --check   # just check if an update is available, exit 0=update available
#
# Dependencies: curl, python3 (stdlib only), makepkg, git

set -euo pipefail

GITHUB_REPO="Draculabo/AntigravityManager"
PKGBUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGBUILD="${PKGBUILD_DIR}/PKGBUILD"
SRCINFO="${PKGBUILD_DIR}/.SRCINFO"

# ── helpers ───────────────────────────────────────────────────────────────────

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*" >&2; }
die()   { echo "[ERROR] $*" >&2; exit 1; }

# Fetch latest GitHub release tag (strips leading 'v')
fetch_latest_version() {
    curl -fsSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'].lstrip('v'))"
}

# Fetch sha256 for a specific asset filename from upstream sha256sums file
fetch_sha256() {
    local version="$1"
    local arch_suffix="$2"   # linux-amd64 | linux-aarch64
    local filename="$3"      # e.g. Antigravity.Manager-0.10.0-1.x86_64.rpm
    local url="https://github.com/${GITHUB_REPO}/releases/download/v${version}/sha256sums-${arch_suffix}.txt"

    local checksum
    checksum=$(curl -fsSL "${url}" | awk -v f="${filename}" '$2 == f {print $1}')

    if [[ -z "${checksum}" ]]; then
        die "Could not find sha256 for '${filename}' in ${url}"
    fi
    echo "${checksum}"
}

# Read current pkgver from PKGBUILD
current_version() {
    grep -m1 '^pkgver=' "${PKGBUILD}" | cut -d= -f2
}

# ── main ──────────────────────────────────────────────────────────────────────

# Parse arguments
CHECK_ONLY=false
TARGET_VERSION=""
for arg in "$@"; do
    case "$arg" in
        --check) CHECK_ONLY=true ;;
        --help|-h)
            sed -n '/^# Usage:/,/^$/p' "$0"
            exit 0
            ;;
        [0-9]*) TARGET_VERSION="$arg" ;;
        *) die "Unknown argument: $arg" ;;
    esac
done

CURRENT_VER="$(current_version)"
info "Current PKGBUILD version : ${CURRENT_VER}"

# Determine target version
if [[ -n "${TARGET_VERSION}" ]]; then
    NEW_VER="${TARGET_VERSION}"
    info "Requested target version : ${NEW_VER}"
else
    info "Fetching latest release from upstream..."
    NEW_VER="$(fetch_latest_version)"
    info "Latest upstream version  : ${NEW_VER}"
fi

# Check if update is needed
if [[ "${NEW_VER}" == "${CURRENT_VER}" ]]; then
    info "Already up to date (${CURRENT_VER}). Nothing to do."
    if "${CHECK_ONLY}"; then exit 1; fi
    exit 0
fi

if "${CHECK_ONLY}"; then
    info "Update available: ${CURRENT_VER} → ${NEW_VER}"
    exit 0
fi

info "Bumping ${CURRENT_VER} → ${NEW_VER}"

# ── fetch checksums ───────────────────────────────────────────────────────────

RPM_X86_64="Antigravity.Manager-${NEW_VER}-1.x86_64.rpm"
RPM_AARCH64="Antigravity.Manager-${NEW_VER}-1.aarch64.rpm"

info "Fetching sha256 for ${RPM_X86_64}..."
SHA256_X86_64="$(fetch_sha256 "${NEW_VER}" "linux-amd64" "${RPM_X86_64}")"
info "  x86_64  : ${SHA256_X86_64}"

info "Fetching sha256 for ${RPM_AARCH64}..."
SHA256_AARCH64="$(fetch_sha256 "${NEW_VER}" "linux-aarch64" "${RPM_AARCH64}")"
info "  aarch64 : ${SHA256_AARCH64}"

# ── patch PKGBUILD ────────────────────────────────────────────────────────────

# Use python3 for reliable in-place editing without GNU sed -i portability issues
python3 - "${PKGBUILD}" "${CURRENT_VER}" "${NEW_VER}" "${SHA256_X86_64}" "${SHA256_AARCH64}" <<'PYEOF'
import sys, re

path, old_ver, new_ver, sha_x86, sha_aa = sys.argv[1:]

with open(path) as fh:
    text = fh.read()

# pkgver
text = re.sub(r'^pkgver=.*$', f'pkgver={new_ver}', text, flags=re.MULTILINE)
# reset pkgrel to 1 on version bump
text = re.sub(r'^pkgrel=.*$', 'pkgrel=1', text, flags=re.MULTILINE)
# sha256_x86_64
text = re.sub(r"(sha256sums_x86_64=\(')[^']+('])", rf"\g<1>{sha_x86}\g<2>", text)
# sha256_aarch64
text = re.sub(r"(sha256sums_aarch64=\(')[^']+('])", rf"\g<1>{sha_aa}\g<2>", text)

with open(path, 'w') as fh:
    fh.write(text)

print(f"PKGBUILD updated: {old_ver} → {new_ver}")
PYEOF

# ── regenerate .SRCINFO ───────────────────────────────────────────────────────

info "Regenerating .SRCINFO..."
(cd "${PKGBUILD_DIR}" && makepkg --printsrcinfo > "${SRCINFO}")
info ".SRCINFO updated."

# ── git commit ───────────────────────────────────────────────────────────────

if git -C "${PKGBUILD_DIR}" rev-parse --git-dir &>/dev/null; then
    git -C "${PKGBUILD_DIR}" add PKGBUILD .SRCINFO
    git -C "${PKGBUILD_DIR}" commit -m "upgpkg: antigravity-manager-bin ${NEW_VER}-1"
    info "Git commit created: upgpkg: antigravity-manager-bin ${NEW_VER}-1"
else
    warn "Not a git repo — skipping commit."
fi

info "Done. Package bumped to ${NEW_VER}-1."
