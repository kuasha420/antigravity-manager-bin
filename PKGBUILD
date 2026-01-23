# Maintainer: FrancoStino <info@davideladisa.it>
pkgname=antigravity-manager-bin
pkgver=0.3.0
pkgrel=3
pkgdesc="Professional multi-account manager for Google Gemini & Claude AI"
arch=('x86_64')
url="https://github.com/Draculabo/AntigravityManager"
license=('LicenseRef-CC-BY-NC-SA-4.0')
depends=('gtk3' 'nss' 'alsa-lib')
optdepends=(
    'libappindicator-gtk3: system tray support'
    'libnotify: desktop notifications'
)
provides=('antigravity-manager')
conflicts=('antigravity-manager' 'antigravity-manager-git')

# Use upstream RPM as source
source=("${pkgname}-${pkgver}.rpm::https://github.com/Draculabo/AntigravityManager/releases/download/v${pkgver}/antigravity-manager-${pkgver}-1.x86_64.rpm")
sha256sums=('4dde116b72ef8de5e5fb55e6761b3715d52c032fdeaca5382e7e453ac822da97')
noextract=("${pkgname}-${pkgver}.rpm")

package() {
    cd "${srcdir}"

    # Extract RPM directly into pkgdir
    bsdtar -xf "${pkgname}-${pkgver}.rpm" -C "${pkgdir}"

    # Fix permissions
    chmod 755 "${pkgdir}/opt/Antigravity Manager/antigravity-manager"

    # Create symlink in /usr/bin
    install -dm755 "${pkgdir}/usr/bin"
    ln -sf "/opt/Antigravity Manager/antigravity-manager" \
        "${pkgdir}/usr/bin/antigravity-manager"

    # Install license
    install -Dm644 "${pkgdir}/opt/Antigravity Manager/LICENSE"* \
        "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE" 2>/dev/null || true
}
