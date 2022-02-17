# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_6 )

inherit distutils-r1

DESCRIPTION="Performance Co-Pilot, system performance and analysis framework"
SRC_URI="https://github.com/performancecopilot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://pcp.io"
KEYWORDS="~amd64"

LICENSE="LGPL-2.1+"
SLOT="0"

IUSE="+threads -ssl -static-probes +infiniband +discovery +systemd +qt5 3d +perl +python +dstat-symlink doc +perfevent -pmdastatsd +pmdapodman +pmdabcc +pmdabpftrace +pmdajson +pmdanutcracker +pmdasnmp +manager +webapi +selinux +transparent-decompression +X"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	3d? ( dev-qt/qt3d )
	systemd? ( sys-apps/systemd )
	qt5? ( dev-qt/qtcore:5 )
	discovery? ( net-dns/avahi[dbus] )
	pmdapodman? ( dev-libs/libvarlink )
	python? ( ${PYTHON_DEPS} )
	perfevent? ( dev-libs/libpfm )
	ssl? ( dev-libs/cyrus-sasl )
	webapi? ( net-libs/libmicrohttpd[messages] )
	X? ( x11-libs/libXt )
"

RDEPEND="${DEPEND}
	acct-group/pcp
	acct-user/pcp"

src_configure() {

	local myconf=(
		--with-threads="$(usex threads)" \
		--with-secure-sockets="$(usex ssl)" \
		--with-static-probes="$(usex static-probes)" \
		--with-infiniband="$(usex infiniband)" \
		--with-discovery="$(usex discovery)" \
		--with-systemd="$(usex systemd)" \
		--with-qt="$(usex qt5)" \
		--with-qt3d="$(usex 3d)" \
		--with-perl="$(usex perl)" \
		--with-python="$(usex python)" \
		--with-python3="$(usex python)" \
		--with-dstat-symlink=$(usex dstat-symlink)
		--with-books=$(usex doc) \
		--with-perfevent="$(usex perfevent)" \
		--with-pmdastatsd="$(usex pmdastatsd)" \
		--with-pmdapodman="$(usex pmdapodman)" \
		--with-pmdabcc="$(usex pmdabcc)" \
		--with-pmdabpftrace="$(usex pmdabpftrace)" \
		--with-pmdajson="$(usex pmdajson)" \
		--with-pmdanutcracker="$(usex pmdanutcracker)" \
		--with-pmdasnmp="$(usex pmdasnmp)" \
		--with-manager="$(usex manager)" \
		--with-webapi="$(usex webapi)" \
		--with-selinux="$(usex selinux)" \
		--with-transparent-decompression="$(usex transparent-decompression)" \
		--with-x="$(usex X)" \
        $(use_enable ssp) \
        $(use_enable pie)
		)

	econf "${myconf[@]}"
}

src_compile(){
	export MAKEOPTS="-j1"
	emake
}

src_install() {
	DIST_ROOT=${D} emake -j1 install
	dodoc CHANGELOG README.md

	systemd_reenable pmcd.service
    systemd_reenable pmlogger.service
    systemd_reenable pmmgr.service
}
