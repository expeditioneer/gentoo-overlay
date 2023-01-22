# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	ahash-0.7.6
	ansi_term-0.12.1
	atty-0.2.14
	autocfg-1.1.0
	base64-0.13.0
	bitflags-1.3.2
	byteorder-1.4.3
	cbindgen-0.9.1
	cc-1.0.73
	cfg-if-1.0.0
	clap-2.34.0
	concread-0.2.21
	crossbeam-0.8.2
	crossbeam-channel-0.5.6
	crossbeam-deque-0.8.2
	crossbeam-epoch-0.9.10
	crossbeam-queue-0.3.6
	crossbeam-utils-0.8.11
	fastrand-1.8.0
	fernet-0.1.4
	foreign-types-0.3.2
	foreign-types-shared-0.1.1
	getrandom-0.2.7
	hashbrown-0.12.3
	hermit-abi-0.1.19
	instant-0.1.12
	itoa-1.0.3
	jobserver-0.1.24
	libc-0.2.132
	lock_api-0.4.7
	log-0.4.17
	lru-0.7.8
	memoffset-0.6.5
	once_cell-1.13.1
	openssl-0.10.41
	openssl-macros-0.1.0
	openssl-sys-0.9.75
	parking_lot-0.11.2
	parking_lot_core-0.8.5
	paste-0.1.18
	paste-impl-0.1.18
	pin-project-lite-0.2.9
	pkg-config-0.3.25
	ppv-lite86-0.2.16
	proc-macro-hack-0.5.19
	proc-macro2-1.0.43
	quote-1.0.21
	rand-0.8.5
	rand_chacha-0.3.1
	rand_core-0.6.3
	redox_syscall-0.2.16
	remove_dir_all-0.5.3
	ryu-1.0.11
	scopeguard-1.1.0
	serde-1.0.143
	serde_derive-1.0.143
	serde_json-1.0.83
	smallvec-1.9.0
	strsim-0.8.0
	syn-1.0.99
	synstructure-0.12.6
	tempfile-3.3.0
	textwrap-0.11.0
	tokio-1.20.1
	tokio-macros-1.8.0
	toml-0.5.9
	unicode-ident-1.0.3
	unicode-width-0.1.9
	unicode-xid-0.2.3
	uuid-0.8.2
	vcpkg-0.2.15
	vec_map-0.8.2
	version_check-0.9.4
	wasi-0.11.0+wasi-snapshot-preview1
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-x86_64-pc-windows-gnu-0.4.0
	zeroize-1.5.7
	zeroize_derive-1.3.2
"

PYTHON_COMPAT=( python3_{9..11} )

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit autotools distutils-r1 systemd tmpfiles cargo

DESCRIPTION="389 Directory Server (core libraries and daemons)"
HOMEPAGE="https://directory.fedoraproject.org/"
SRC_URI="https://github.com/389ds/${PN}/archive/refs/tags/${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
LICENSE="GPL-3+ Apache-2.0 BSD MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE_PLUGINS="+accountpolicy +bitwise +dna +pam-passthru"
# TODO: check if bpkdf2 required on openldap? -> should be needed
# TODO: check if sha2 required on openldap?
IUSE="${IUSE_PLUGINS} +autobind auto-dn-suffix debug doc +jemalloc +ldapi selinux systemd test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# lib389 tests (which is most of the suite) can't find their own modules.
RESTRICT="test"

# Do not add any AGPL-3 BDB here!
# See bug 525110, comment 15.

DEPEND="
	>=app-crypt/mit-krb5-1.7-r100[openldap]
	dev-db/lmdb:=
	>=dev-libs/cyrus-sasl-2.1.19:2[kerberos]
	>=dev-libs/icu-60.2:=
	dev-libs/nspr
	>=dev-libs/nss-3.22[utils]
	dev-libs/libevent:=
	dev-libs/libpcre:3
	dev-libs/openssl:0=
	>=net-analyzer/net-snmp-5.1.2:=
	net-nds/openldap[pbkdf2,sasl,sha2]
	sys-libs/cracklib
	sys-libs/db:5.3
	sys-fs/e2fsprogs
	pam-passthru? ( sys-libs/pam )
	selinux? (
		$(python_gen_cond_dep '
			sys-libs/libselinux[python,${PYTHON_USEDEP}]
		')
	)
	systemd? ( >=sys-apps/systemd-244 )
	virtual/libcrypt:=
	"

BDEPEND=">=sys-devel/autoconf-2.69-r5
	virtual/pkgconfig
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/argparse-manpage[${PYTHON_USEDEP}]
	')
	doc? ( app-doc/doxygen )
	test? ( dev-util/cmocka )
"

# perl dependencies are for logconv.pl
RDEPEND="${DEPEND}
	!net-nds/389-ds-base:1.4
	acct-user/dirsrv
	acct-group/dirsrv
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pyasn1[${PYTHON_USEDEP}]
		dev-python/pyasn1-modules[${PYTHON_USEDEP}]
		dev-python/argcomplete[${PYTHON_USEDEP}]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/python-ldap[sasl,${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
	')
	virtual/perl-Archive-Tar
	virtual/perl-DB_File
	virtual/perl-IO
	virtual/perl-Getopt-Long
	virtual/perl-IO-Compress
	virtual/perl-MIME-Base64
	virtual/perl-Scalar-List-Utils
	virtual/perl-Time-Local
	virtual/logger
	jemalloc? ( dev-libs/jemalloc )
	selinux? ( sec-policy/selinux-dirsrv )
"

S="${WORKDIR}/${PN}-${P}"

PATCHES=(
	"${FILESDIR}/${PN}-db-gentoo.patch"
)

distutils_enable_tests pytest

src_prepare() {
	# https://github.com/389ds/389-ds-base/issues/4292
	if use !systemd; then
		sed -i \
			-e 's|WITH_SYSTEMD = 1|WITH_SYSTEMD = 0|' \
			Makefile.am || die
	fi

	if use jemalloc; then
		sed -i \
			-e "s Environment=LD_PRELOAD=@libdir@/@package_name@/lib/libjemalloc.so.2 Environment=LD_PRELOAD=${EPREFIX}/usr/$(get_libdir)/libjemalloc.so.2 " \
			wrappers/systemd.template.service.custom.conf.in || die
	else
		sed -i \
			-e 's Environment=LD_PRELOAD=@libdir@/@package_name@/lib/libjemalloc.so.2  ' \
			wrappers/systemd.template.service.custom.conf.in || die
	fi

	sed -i -e 's EnvironmentFile=-@initconfigdir@/@package_name@.*  ' \
		 wrappers/systemd.template.service.in || die

	default

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable accountpolicy acctpolicy)
		$(use_enable bitwise)
		$(use_enable dna)
		$(use_enable pam-passthru)
		$(use_enable autobind)
		$(use_enable auto-dn-suffix)
		$(use_enable debug)
		$(use_enable ldapi)
		$(use_with selinux)
		$(use_with systemd)
		$(use_with systemd systemdgroupname "dirsrv.target")
		$(use_with systemd tmpfiles-d "/usr/lib/tmpfiles.d")
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		$(use_with !systemd initddir "/etc/init.d")
		$(use_enable test cmocka)
		--enable-rust-offline
		--with-pythonexec="${PYTHON}"
		--with-fhs
		--with-openldap
		--with-libldap-r=no
		--with-db-inc="${EPREFIX}"/usr/include/db5.3
		--disable-cockpit
	)

	econf "${myeconfargs[@]}"

	rm "${S}"/.cargo/config || die
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	default

	if use doc; then
		doxygen "${S}"/docs/slapi.doxy || die
	fi

	cd "${S}"/src/lib389 || die
	distutils-r1_src_compile

	# argparse-manpage dynamic man pages have hardcoded man v1 in header
	sed -i \
		"1s/\"1\"/\"8\"/" \
		"${S}"/src/lib389/man/{openldap_to_ds,ds{conf,ctl,idm,create}}.8 || die
}

src_test () {
	emake check
	cd "${S}"/src/lib389 || die
	distutils-r1_src_test
}

src_install() {
	# -j1 is a temporary workaround for bug #605432
	emake -j1 DESTDIR="${D}" install

	# Install gentoo style init script
	# Get these merged upstream
	newinitd "${FILESDIR}"/389-ds.initd-r1 389-ds
	newinitd "${FILESDIR}"/389-ds-snmp.initd 389-ds-snmp

	dotmpfiles "${FILESDIR}"/389-ds-base.conf

	# cope with libraries being in /usr/lib/dirsrv
	dodir /etc/env.d
	echo "LDPATH=/usr/$(get_libdir)/dirsrv" > "${ED}"/etc/env.d/08dirsrv || die

	if use doc; then
		cd "${S}" || die
		docinto html/
		dodoc -r html/.
	fi

	cd "${S}"/src/lib389 || die
	distutils-r1_src_install
	python_fix_shebang "${ED}"

	find "${ED}" -type f \( -name "*.a" -o -name "*.la" \) -delete || die
}

pkg_postinst() {
	tmpfiles_process 389-ds-base.conf

	echo
	elog "If you are planning to use 389-ds-snmp (ldap-agent),"
	elog "make sure to properly configure: /etc/dirsrv/config/ldap-agent.conf"
	elog "adding proper 'server' entries, and adding the lines below to"
	elog " => /etc/snmp/snmpd.conf"
	elog
	elog "master agentx"
	elog "agentXSocket /var/agentx/master"
	elog
	elog "To start 389 Directory Server (LDAP service) at boot:"
	elog
	elog "    rc-update add 389-ds default"
	elog
	echo
}

# TODO: warning below
# * Verifying compiled files for python3.10
# *
# * QA Notice: This package installs one or more compiled Python modules whose
# * .py files have different content (size or hash) than recorded:
# *
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.opt-1.pyc
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.opt-2.pyc
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.pyc
# *
# * QA Notice: This package installs one or more compiled Python modules whose
# * .py files have different timestamps than recorded:
# *
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.opt-1.pyc
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.opt-2.pyc
# *   /usr/lib/python3.10/site-packages/lib389/__pycache__/perftools.cpython-310.pyc
# *
# * For more information on bytecode files and related issues, please see:
# *   https://projects.gentoo.org/python/guide/qawarn.html#compiled-bytecode-related-warnings
