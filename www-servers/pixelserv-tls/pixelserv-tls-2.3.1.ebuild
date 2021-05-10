# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools systemd

DESCRIPTION="Serve one transparent pixel for ad blocking"
HOMEPAGE="https://github.com/kvic-z/pixelserv-tls/wiki"
SRC_URI="https://github.com/kvic-z/pixelserv-tls/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="LGPL-3"
KEYWORDS="~amd64 ~arm"

IUSE=""

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default

    systemd_dounit "${FILESDIR}"/${PN}.service

	dodoc ChangeLog || die
	doman ${PN}.1 || die
}

pkg_postinst() {
	ewarn "Make sure, that You supply pixelserv-tls with the appropriate "
	ewarn "CA certificate. Also note, that You have to ensure that Your"
	ewarn "clients do accept the certificate"

	elog  "see: https://github.com/kvic-z/pixelserv-tls/wiki"
}
