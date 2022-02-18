# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )
inherit distutils-r1 systemd tmpfiles

DESCRIPTION="Performance Co-Pilot, system performance and analysis framework"
SRC_URI="https://github.com/performancecopilot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://pcp.io"
KEYWORDS="~arm ~arm64 ~amd64"

LICENSE="LGPL-2.1+"
SLOT="0"

IUSE="3d +dstat-symlink doc infiniband +manager +perfevent perl +pmdabcc pmdabpf +pmdabpftrace +pmdajson pmdapodman pmdastatsd +pmdanutcracker +pmdasnmp +python +qt5 ssl ssp static-probes selinux systemd transparent-decompression +threads zeroconf"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	dev-libs/libuv:0=
	net-misc/rsync
	sys-process/procps
	sys-apps/which
	dev-python/PyQt5[${PYTHON_USEDEP},svg]
	dev-python/openpyxl[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-util/ragel
	net-libs/libmicrohttpd
	pmdapodman? ( dev-libs/libvarlink )
	systemd? ( sys-apps/systemd )
	python? ( ${PYTHON_DEPS} )
	perfevent? ( dev-libs/libpfm )
	perl? (
		dev-perl/DBD-mysql
		dev-perl/File-Slurp
		dev-perl/JSON
		dev-perl/libxml-perl
		dev-perl/libwww-perl
		dev-perl/Net-SNMP
		dev-perl/YAML-LibYAML
	)
	qt5? (
	  dev-qt/qtconcurrent:5
	  dev-qt/qtcore:5
	  dev-qt/qtnetwork:5
	  dev-qt/qtprintsupport:5
  )
	ssl? ( dev-libs/cyrus-sasl )
	zeroconf? ( net-dns/avahi[dbus] )
"

RDEPEND="${DEPEND}
	acct-group/pcp
	acct-user/pcp"

PATCHES=(
	"${FILESDIR}/${PN}-sys-stat.patch"
)

src_configure() {

	local myconf=(
    --prefix="${EPREFIX}"/usr
    --sbindir="${EPREFIX}"/usr/sbin
    --libexecdir="${EPREFIX}"/usr/$(get_libdir)
    --sysconfdir="${EPREFIX}"/etc
    --localstatedir="${EPREFIX}"/var
    --with-rundir="${EPREFIX}"/run/pcp
		$(use_with threads)
		$(use_with ssl secure-sockets)
		$(use_with static-probes)
		$(use_with infiniband)
		$(use_with zeroconf discovery)
		$(use_with systemd)
		$(use_with qt5 qt)
		$(use_with 3d qt3d)
		$(use_with perl)
		--without-python
		--with-python3
		$(use_with dstat-symlink)
		$(use_with perfevent)
		$(use_with pmdastatsd)
		$(use_with pmdapodman)
		$(use_with pmdabcc)
		$(use_with pmdabpf)
		$(use_with pmdabpftrace)
		$(use_with pmdajson)
		$(use_with pmdanutcracker)
		$(use_with pmdasnmp)
		--with-make=${MAKE:-make}
		$(use_with transparent-decompression)
		#$(use_with selinux)  # DISABLED due to missing SELINUX POLICY module
	)

	case "${ABI}" in
		*64*) myconf+=( --with-64bit ) ;;
		*) myconf+=( --without-64bit ) ;;
	esac

	econf "${myconf[@]}"
}

src_compile(){
	export MAKEOPTS="-j1"
	emake
}

src_install() {
	DIST_ROOT=${D} emake -j1 install
	dodoc CHANGELOG README.md
	newtmpfiles "${FILESDIR}"/${PN}.tmpfiles.conf ${PN}.conf
}

pkg_postinst() {
	cd "${EROOT}"/var/lib/pcp/pmns && ./Rebuild || die 'rebuild failed'

	if use systemd; then
		systemd_reenable pmcd.service
		systemd_reenable pmlogger.service
		systemd_reenable pmmgr.service
	fi
}
