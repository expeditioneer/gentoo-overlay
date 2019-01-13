# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )
PYTHON_REQ_USE="sqlite,threads"

inherit distutils-r1 gnome2-utils virtualx

DESCRIPTION="Lutris is an open source gaming platform for GNU/Linux."
HOMEPAGE="https://lutris.net/"

if [[ "${PV}" == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/lutris/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/lutris/${PN}/releases/tag/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	app-portage/gentoolkit
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/python-evdev[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	net-libs/libsoup
	x11-apps/xgamma"

DEPEND="
	test? (
		${RDEPEND}
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
	)"

python_install() {
	distutils-r1_python_install
}

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	distutils-r1_src_compile
}

python_test() {
	rm --force tests/fixtures/pga.db
	rm --force --recursive tests/coverage/
	virtx nosetests --verbose || die "Tests fail with ${EPYTHON}"
}

src_install() {
	# README.rst contains list of optional deps
	DOCS=( AUTHORS README.rst INSTALL.rst )
	distutils-r1_src_install
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update

	elog "For a list of optional dependencies (runners) see:"
	elog "/usr/share/doc/${PF}/README.rst.bz2"
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
