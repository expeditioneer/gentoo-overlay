# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )

DISTUTILS_SINGLE_IMPL=1

# autotools are terribly broken on this software
inherit bash-completion-r1 python-single-r1 systemd tmpfiles

DESCRIPTION="Performance Co-Pilot, system performance and analysis framework"
SRC_URI="https://github.com/performancecopilot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://pcp.io"
KEYWORDS="~amd64 ~arm ~arm64"

LICENSE="LGPL-2.1+"
SLOT="0"

IUSE="3d +dstat-symlink doc infiniband +manager +perfevent perl +pmdabcc pmdabpf +pmdabpftrace +pmdajson pmdapodman pmdastatsd +pmdanutcracker +pmdasnmp +python +qt5 -ssl ssp static-probes selinux systemd transparent-decompression test zabbix zeroconf"
RESTRICT="!test? ( test )"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	dev-libs/libuv:0=
	net-misc/rsync
	sys-process/procps
	sys-apps/which
	$(python_gen_cond_dep '
		dev-python/PyQt5[${PYTHON_USEDEP},svg]
		dev-python/openpyxl[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')
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
	ssl? (
		dev-libs/cyrus-sasl
		dev-libs/nss
	 )
	zeroconf? ( net-dns/avahi[dbus] )
"

RDEPEND="${DEPEND}
	acct-group/pcp
	acct-user/pcp"

PATCHES=(
	"${FILESDIR}/${PN}-5.3.6-bash-completion.patch"
	"${FILESDIR}/${PN}-5.3.6-sys-stat.patch"
)

src_prepare() {
		default

		find ./ -type f -name "*.service.in" -exec sed \
		-e "/^EnvironmentFile=.*/d" \
		-i {} + || die "removal of EnvironmentFile from systemd services failed"

		find . -type f -exec sed \
		-e "s/pcp-doc/${PF}/g" \
		-i {} + || die "fixing documentation paths failed"

		sed -i \
			-e 's#ifeq (, $(filter debian suse, $(PACKAGE_DISTRIBUTION)))#ifeq (, $(filter debian gentoo suse, $(PACKAGE_DISTRIBUTION)))#g' \
				GNUmakefile   || die "could not disable run directory creation"

		sed -i \
			-e "s#^pcp_bashshare_dir=.*#pcp_bashshare_dir=$(get_bashcompdir)#g" \
			configure.ac || die "could not set bashcompdir"

		# TODO: fix installation of qa subdir stuff when tests are enabled
		#! use test && sed -i -e "/SUBDIRS += qa/d" GNUmakefile

		sed -i \
			-e "s#^HAVE_GZIPPED_MANPAGES = .*#HAVE_GZIPPED_MANPAGES = false#g" \
			-e "s#^HAVE_BZIP2ED_MANPAGES = .*#HAVE_BZIP2ED_MANPAGES = false#g" \
			-e "s#^HAVE_LZMAED_MANPAGES = .*#HAVE_LZMAED_MANPAGES = false#g" \
			-e "s#^HAVE_XZED_MANPAGES = .*#HAVE_XZED_MANPAGES = false#g" \
			src/include/builddefs.in || die "could not disable automatic manpage compression"

		if ! use zabbix; then
			sed -i -e	"/pcp2zabbix/d" src/GNUmakefile || die "could not disable zabbix support"

			sed -i \
				-e "#pcp2zabbix)#,#;;#d" \
				-e "s#pcp2zabbix ##g" \
				 src/bashrc/pcp_completion.sh || die "could not disable zabbix bash-completion"
		fi
}

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}"/usr
		--sbindir="${EPREFIX}"/usr/sbin
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)
		--sysconfdir="${EPREFIX}"/etc
		--localstatedir="${EPREFIX}"/var
		--with-rundir="${EPREFIX}"/run/pcp
		--with-sysconfigdir="${EPREFIX}"/etc/conf.d
		-with-threads
		--without-secure-sockets # $(use_with ssl secure-sockets) - disabled because secure-sockets require NSS and that's not working as expected therefore disabled
		$(use_with static-probes)
		$(use_with infiniband)
		$(use_with zeroconf discovery)
		$(use_with systemd)
		$(use_with qt5 qt)
		$(use_with 3d qt3d)
		$(use_with perl)
		--with-python=no
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
	python_optimize

	keepdir /var/lib/pcp/config/pmda
	keepdir /var/lib/pcp/config/pmie
	keepdir /var/lib/pcp/pmcd
	keepdir /var/lib/pcp/tmp/bash
	keepdir /var/lib/pcp/tmp/json
	keepdir /var/lib/pcp/tmp/mmv
	keepdir /var/lib/pcp/tmp/pmie
	keepdir /var/lib/pcp/tmp/pmlogger
	keepdir /var/lib/pcp/tmp/pmproxy
	keepdir /var/log/pcp/pmcd
	keepdir /var/log/pcp/pmfind
	keepdir /var/log/pcp/pmie
	keepdir /var/log/pcp/pmlogger
	keepdir /var/log/pcp/pmproxy
	keepdir /var/log/pcp/sa
}

pkg_postinst() {
	cd "${EROOT}"/var/lib/pcp/pmns && ./Rebuild || die 'rebuild failed'

	tmpfiles_process ${PN}.conf

	if use systemd; then
		systemd_reenable pmcd.service
		systemd_reenable pmlogger.service
		systemd_reenable pmmgr.service
	fi
}
