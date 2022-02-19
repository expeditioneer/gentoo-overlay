# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools pam systemd

DESCRIPTION="A sysadmin login session in a web browser"
HOMEPAGE="http://cockpit-project.org/"

SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="
	LGPL-2.1+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

IUSE="branding doc maintainer-mode +pcp policykit +ssh systemd debug test"

KEYWORDS="~arm ~arm64 ~amd64"
RESTRICT="!test? ( test )"

REQUIRED_USE="systemd"

DEPEND="
	>=app-crypt/mit-krb5-1.11
	>=dev-libs/json-glib-1.0
	>=net-libs/gnutls-3.4.3
	pcp? ( sys-apps/pcp )
	policykit? ( sys-auth/polkit )
	ssh? ( >=net-libs/libssh-0.8.5[server] )
	systemd? ( >=sys-apps/systemd-235 )
"

RDEPEND="${DEPEND}
	acct-group/cockpit-ws
	acct-group/cockpit-wsinstance
	acct-user/cockpit-ws
	acct-user/cockpit-wsinstance
"

# TODO: dependencies
#GLIB_VERSION="2.50"
#LIBSSH_VERSION="0.8.5"
#
#GIO_REQUIREMENT="gio-unix-2.0 >= $GLIB_VERSION gio-2.0 >= $GLIB_VERSION"
#LIBSYSTEMD_REQUIREMENT="libsystemd >= 235"
#JSON_GLIB_REQUIREMENT="json-glib-1.0 >= 1.4"
#POLKIT_REQUIREMENT="polkit-agent-1 >= 0.105"
#GNUTLS_REQUIREMENT="gnutls >= 3.6.0"
#KRB5_REQUIREMENT="krb5-gssapi >= 1.11 krb5 >= 1.11"


PATCHES=(
	"${FILESDIR}"/cockpit-263-remove-other-distro-branding.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {

	local myconf=(
		--localstatedir="${EPREFIX}"/var
		--with-systemdunitdir="$(systemd_get_systemunitdir)"
		--with-pamdir="$(getpam_mod_dir)"
		--with-cockpit-user=cockpit-ws
		--with-cockpit-group=cockpit-ws
		--with-cockpit-ws-instance-user=cockpit-wsinstance
		--with-cockpit-ws-instance-group=cockpit-wsinstance
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable pcp)
    $(use_enable policykit polkit)
		$(use_enable maintainer-mode)
		$(use_enable ssh))

	econf "${myconf[@]}"
}
src_install(){
	emake DESTDIR="${D}"  install || die

	ewarn "Installing experimental pam configuration file"
	ewarn "use at your own risk"
	newpamd "${FILESDIR}"/cockpit.pam cockpit

	if use branding; then
		dodir /usr/share/cockpit/branding/gentoo/
		cp --recursive "${FILESDIR}"/theme/. "${D}"/usr/share/cockpit/branding/gentoo/
	fi

	dodoc README.md AUTHORS

	systemd_reenable cockpit.socket
}
