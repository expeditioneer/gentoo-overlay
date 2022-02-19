# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools pam systemd tmpfiles

DESCRIPTION="A sysadmin login session in a web browser"
HOMEPAGE="http://cockpit-project.org/"

SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="
	LGPL-2.1+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

IUSE="branding doc debug kdump +pcp policykit selinux +ssh systemd test"

KEYWORDS="~arm ~arm64 ~amd64"
RESTRICT="!test? ( test )"

REQUIRED_USE="systemd"

DEPEND="
	>=app-crypt/mit-krb5-1.11
	>=dev-libs/json-glib-1.4
	dev-util/gdbus-codegen
	>=net-libs/gnutls-3.6.0
	>=sys-libs/glibc-2.5
	virtual/libcrypt:=
	kdump? ( sys-apps/kexec-tools )
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

# Missing dependencies
# PackageKit
# https://github.com/sgallagher/sscg

#>>> /usr/share/cockpit/static/fonts/RedHatText-Regular.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatText-MediumItalic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatText-Medium.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatText-Italic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatText-BoldItalic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatText-Bold.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-Regular.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-MediumItalic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-Medium.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-Italic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-BoldItalic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-Bold.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-BlackItalic.woff2
#>>> /usr/share/cockpit/static/fonts/RedHatDisplay-Black.woff2

#rm -r %{buildroot}/%{_prefix}/%{__lib}/cockpit-test-assets
## files from -pcp
#rm -r %{buildroot}/%{_libexecdir}/cockpit-pcp %{buildroot}/%{_localstatedir}/lib/pcp/
## files from -storaged
#rm -f %{buildroot}/%{_prefix}/share/metainfo/org.cockpit-project.cockpit-storaged.metainfo.xml

#>>> /lib/systemd/system/cockpit-wsinstance-https@.socket
#>>> /lib/systemd/system/cockpit-wsinstance-https@.service
#>>> /lib/systemd/system/cockpit-wsinstance-https-factory.socket
#>>> /lib/systemd/system/cockpit-wsinstance-https-factory@.service
#>>> /lib/systemd/system/cockpit-wsinstance-http.socket
#>>> /lib/systemd/system/cockpit-wsinstance-http.service
#>>> /lib/systemd/system/cockpit.socket
#>>> /lib/systemd/system/cockpit.service
#>>> /lib/systemd/system/cockpit-motd.service
#>>> /lib/systemd/system/system-cockpithttps.slice

PATCHES=(
	"${FILESDIR}"/cockpit-263-remove-other-distro-branding.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {

	local myconf=(
		--libexecdir="/usr/$(get_libdir)"
		--localstatedir="${EPREFIX}"/var
		--sysconfdir="${EPREFIX}"/etc
		--with-pamdir="$(getpam_mod_dir)"
		--with-systemdunitdir="$(systemd_get_systemunitdir)"
		--with-cockpit-user=cockpit-ws
		--with-cockpit-group=cockpit-ws
		--with-cockpit-ws-instance-user=cockpit-wsinstance
		--with-cockpit-ws-instance-group=cockpit-wsinstance
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable pcp)
		$(use_enable policykit polkit)
		$(use_enable ssh)
	)

	econf "${myconf[@]}"
}
src_install(){
	emake DESTDIR="${D}" install || die

	ewarn "Installing experimental pam configuration file"
	ewarn "use at your own risk"
	newpamd "${FILESDIR}"/cockpit.pam cockpit

	if use branding; then
		dodir /usr/share/cockpit/branding/gentoo/
		cp --recursive "${FILESDIR}"/theme/. "${D}"/usr/share/cockpit/branding/gentoo/
	fi

	if ! use selinux; then
		rm -r "${D}"/usr/share/cockpit/selinux
	fi

	if ! use kdump; then
		rm -r "${D}"/usr/share/cockpit/kdump
	fi

	dodoc README.md AUTHORS

	systemd_reenable cockpit.socket

	keepdir /etc/cockpit/ws-certs.d
	chown -R cockpit-ws:cockpit-ws "${D}/etc/cockpit/ws-certs.d"
}
