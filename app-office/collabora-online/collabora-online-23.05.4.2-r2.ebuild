# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools fcaps systemd

MY_PV=$(ver_cut 1-3)-$(ver_cut 4)

DESCRIPTION="A collaborative online office suite based on LibreOffice technology."
HOMEPAGE="https://collaboraonline.github.io/"
SRC_URI="
	https://github.com/CollaboraOnline/online/archive/refs/tags/cp-${MY_PV}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/CollaboraOnline/online/releases/download/for-code-assets/core-co-$(ver_cut 1-2)-assets.tar.gz
		-> ${P}-assets.gh.tar.gz
"

LICENSE="MPL-2.0"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	acct-user/cool
	app-office/libreoffice
	net-libs/nodejs
	dev-libs/poco
	dev-python/polib
"

RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-23.05.4.2-coolwsd.service.patch
	"${FILESDIR}"/${PN}-23.05.4.2-coolwsd.xml.in.patch
)

S="${WORKDIR}/online-cp-${MY_PV}"

FILECAPS=(
	"cap_chown+ep cap_fowner+ep cap_sys_chroot+ep cap_mknod+ep" usr/bin/coolforkit --
	"cap_sys_admin+ep" usr/bin/coolmount
)

src_prepare() {
	sed --in-place \
		--expression='s#nginxconfigdir = ${sysconfdir}/nginx/snippets#nginxconfigdir = ${sysconfdir}/nginx/conf.d/collabora#g' \
		Makefile.am || die

	default
	eautoreconf

	# TODO: fetch NPM dependencies - currently only working when 'FEATURES="-network-sandbox" is set :-(
	cd browser && npm update --no-audit
}

src_configure() {
local ENABLE_GTKAPP=no

	local myeconfargs=(
		--with-lo-path="/usr/$(get_libdir)/libreoffice"
		--with-lokit-path="${WORKDIR}/include"
		--with-vendor=gentoo
		--disable-setcap
		--disable-tests
		--disable-werror
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
	systemd_newunit coolwsd.service collabora-online.service

	keepdir /var/lib/coolwsd/{systemplate,jails}
	fowners -R cool:cool /var/lib/coolwsd
}

pkg_postinst() {
	fcaps_pkg_postinst

	elog "If you need to use WOPI security, generate an RSA key using this command:"
	elog "#sudo coolconfig generate-proof-key"
	elog "or if your config dir is not /etc, you can run ssh-keygen manually:"
	elog "#ssh-keygen -t rsa -N \"\" -m PEM -f \"/etc/coolwsd/proof_key\""
	elog "Note: the proof_key file must be readable by the coolwsd process."
}
