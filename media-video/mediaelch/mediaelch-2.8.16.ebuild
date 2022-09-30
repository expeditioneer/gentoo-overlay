# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Media Manager for Kodi"
SRC_URI="https://github.com/Komet/MediaElch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="http://www.mediaelch.de/"
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="doc lto test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/quazip:0=
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5[widgets]
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtdeclarative:5[widgets]
	dev-qt/qtsql:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	media-video/mediainfo
	doc? ( app-doc/doxygen[dot] )"

S="${WORKDIR}/MediaElch-${PV}"

src_prepare() {
	if ! use doc ; then
		sed -i \
			-e '/add_subdirectory(docs)/d' \
			CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure()
{
	local CMAKE_BUILD_TYPE="Release"

	local mycmakeargs=(
		-DUSE_EXTERN_QUAZIP=0N
		-DDISABLE_UPDATER=ON
		-DENABLE_LTO=$(usex lto)
		-DENABLE_TESTS=$(usex test)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	dolib.a "${WORKDIR}/MediaElch-${PV}_build/src/liblibmediaelch.a" || die
}
