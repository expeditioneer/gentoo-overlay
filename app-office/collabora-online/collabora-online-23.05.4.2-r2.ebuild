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

src_prepare() {
	sed --in-place \
		--expression='s#nginxconfigdir = ${sysconfdir}/nginx/snippets#nginxconfigdir = ${sysconfdir}/nginx/conf.d#g' \
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
	emake install DESTDIR="${D}" PREFIX="/usr"
	systemd_newunit coolwsd.service collabora-online.service

    keepdir /var/lib/coolwsd
    fowners ${PN}:${PN} /var/lib/coolwsd
}

pkg_postinst() {
    fcaps cap_chown cap_fowner cap_sys_chroot=ep cap_mknod - /usr/bin/coolforkit
    fcaps cap_sys_admin=ep /usr/bin/coolmount

    einfo "If you need to use WOPI security, generate an RSA key using this command:"
    einfo "#sudo coolconfig generate-proof-key"
    einfo "or if your config dir is not /etc, you can run ssh-keygen manually:"
    einfo "#ssh-keygen -t rsa -N \"\" -m PEM -f \"/etc/coolwsd/proof_key\""
    einfo "Note: the proof_key file must be readable by the coolwsd process."
}

#     cd "${pkgdir}"/usr/local/
#     mv etc ../../
#     mv bin ../
#     mv share ../
#     cd ..
#     rm local -r
#     cd "${pkgdir}"/etc
#     mkdir -p httpd/conf/extra
#     mv apache2/conf-available/coolwsd.conf httpd/conf/extra/
#     rm -r apache2
#     cd "${pkgdir}"
#     mkdir -p var/lib/coolwsd/systemplate
#     cp -r "${srcdir}"/instdir "${pkgdir}"/usr/share/coolwsd/libreoffice
# cp -r "${WORKDIR}/instdir" "${D}/test/bins" || die

# TODO:
# create /var/lib/coolwsd/systemplate (permissions)
# create /var/lib/coolwsd/jails (permissions)

# provide /etc/coolwsd/ca-chain.cert.pem
# provide etc/coolwsd/key.pem
