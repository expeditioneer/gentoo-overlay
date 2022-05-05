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

IUSE="branding debug doc kdump networkmanager +pcp policykit selinux +ssh systemd test udisks"
REQUIRED_USE="systemd"

KEYWORDS="~amd64 ~arm64"
RESTRICT="!test? ( test )"

DEPEND="
	>=app-crypt/mit-krb5-1.11
	>=dev-libs/json-glib-1.4
	dev-util/gdbus-codegen
	>=net-libs/gnutls-3.6.0
	>=sys-libs/glibc-2.5
	virtual/libcrypt:=
	kdump? ( sys-apps/kexec-tools )
	networkmanager? ( net-misc/networkmanager:= )
	pcp? ( sys-apps/pcp )
	policykit? ( sys-auth/polkit )
	udisks? ( sys-fs/udisks )
	ssh? ( >=net-libs/libssh-0.8.5[server] )
	systemd? ( >=sys-apps/systemd-235 )
"

RDEPEND="${DEPEND}
	acct-group/cockpit-ws
	acct-group/cockpit-wsinstance
	acct-user/cockpit-ws
	acct-user/cockpit-wsinstance
"

PATCHES=(
	"${FILESDIR}"/cockpit-263-remove-other-distro-branding.patch
	"${FILESDIR}"/cockpit-268.1-fix-jobserver-unavailable.patch
)

src_prepare() {
	default
	eautoreconf

	if ! use kdump; then
		sed -i -e "s#pkg/kdump/org.cockpit-project.cockpit-kdump.metainfo.xml##" "${S}"/pkg/Makefile.am || die
		sed -i -e "s#kdump##" "${S}"/pkg/build || die
		rm -r "${S}"/pkg/kdump
	fi

	if ! use networkmanager; then
		sed -i -e "s#networkmanager##" "${S}"/pkg/build || die
		rm -r "${S}"/pkg/networkmanager
	fi

	if ! use selinux; then
		sed -i -e "s#pkg/selinux/org.cockpit-project.cockpit-selinux.metainfo.xml##" "${S}"/pkg/Makefile.am || die
		sed -i -e "s#selinux##" "${S}"/pkg/build || die
		rm -r "${S}"/pkg/selinux
	fi

	if ! use udisks; then
		sed -i -e "s#pkg/storaged/org.cockpit-project.cockpit-storaged.metainfo.xml##" "${S}"/pkg/Makefile.am || die
		sed -i -e "s#storaged##" "${S}"/pkg/build || die
		rm -r "${S}"/pkg/storaged
	fi

	for package in sosreport packagekit playground; do
		rm -r "${S}"/pkg/${package}
	done

	sed -i \
		-e "s#pkg/sosreport/org.cockpit-project.cockpit-sosreport.metainfo.xml##" \
		-e "s#pkg/sosreport/cockpit-sosreport.png##" "${S}"/pkg/Makefile.am || die

	sed -i \
		-e "s#sosreport##" \
		-e "s#packagekit##" \
		-e "s#playground##" "${S}"/pkg/build || die
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
		--enable-asan=no
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

	dodoc README.md AUTHORS

	keepdir /etc/cockpit/ws-certs.d
	chown -R cockpit-ws:cockpit-ws "${D}/etc/cockpit/ws-certs.d"
}

pkg_postinst() {
	tmpfiles_process cockpit-tempfiles.conf
}
