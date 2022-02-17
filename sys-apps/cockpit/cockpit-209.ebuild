# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user pam autotools eutils systemd

DESCRIPTION="A sysadmin login session in a web browser"
HOMEPAGE="http://cockpit-project.org/"

SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="
	LGPL-2.1+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

IUSE="branding doc maintainer-mode +pcp +ssh systemd debug test"

KEYWORDS="~amd64"
RESTRICT="!test? ( test )"

REQUIRED_USE="systemd"

PATCHES=(
	"${FILESDIR}"/cockpit-209-remove-other-distro-branding.patch
	"${FILESDIR}"/cockpit-209-firewalld.patch)

DEPEND="
	ssh? ( >=net-libs/libssh-0.8.5[server] )
	pcp? ( sys-apps/pcp )
	>=app-crypt/mit-krb5-1.11
	>=dev-libs/json-glib-1.0
	>=net-libs/gnutls-3.4.3
	systemd? ( >=sys-apps/systemd-235 )
	>=sys-auth/polkit-0.105
"

RDEPEND="${DEPEND}
	acct-group/cockpit-ws
	acct-group/cockpit-wsinstance
	acct-user/cockpit-ws
	acct-user/cockpit-wsinstance
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {

	local myconf=(
		--with-cockpit-user=cockpit-ws
		--with-cockpit-group=cockpit-ws
		--with-cockpit-ws-instance-user=cockpit-wsinstance
		--with-cockpit-ws-instance-group=cockpit-wsinstance
		--localstatedir="${EPREFIX}"/var
		--with-systemdunitdir="$(systemd_get_systemunitdir)"
		--with-pamdir="$(getpam_mod_dir)"
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable pcp)
		$(use_enable maintainer-mode)
		$(use_enable ssh))

	econf "${myconf[@]}"
}
src_install(){
	emake DESTDIR="${D}"  install || die

	ewarn "Installing experimetal pam configuration file"
	ewarn "use at your own risk"
	newpamd "${FILESDIR}"/cockpit.pam cockpit

	if use branding; then
		dodir /usr/share/cockpit/branding/gentoo/
		cp --recursive "${FILESDIR}"/theme/. "${D}"/usr/share/cockpit/branding/gentoo/
	fi

	dodoc README.md AUTHORS

	systemd_reenable cockpit.socket
}
