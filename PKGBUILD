# Maintainer: FrancoStino <info@davideladisa.it>
pkgname=antigravity-manager-bin
pkgver=0.3.0
pkgrel=2
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
source=("${pkgname}-${pkgver}.deb::https://github.com/Draculabo/AntigravityManager/releases/download/v${pkgver}/antigravity-manager_${pkgver}_amd64.deb")
sha256sums=('0c9be9fa122c35ea50154e1b583c12ebd51975624dc0c4ec567d7b0e0c0d7722')
noextract=("${pkgname}-${pkgver}.deb")

package() {
    # Extract .deb package
    cd "${srcdir}"
    bsdtar -xf "${pkgname}-${pkgver}.deb"
    bsdtar -xf data.tar.xz -C "${pkgdir}"

    # Fix permissions
    chmod 755 "${pkgdir}/opt/Antigravity Manager/antigravity-manager"
    
    # Create symlink in /usr/bin
    install -dm755 "${pkgdir}/usr/bin"
    ln -sf "/opt/Antigravity Manager/antigravity-manager" "${pkgdir}/usr/bin/antigravity-manager"

    # Install license
    install -Dm644 "${pkgdir}/opt/Antigravity Manager/LICENSE"* \
        "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE" 2>/dev/null || true
}
