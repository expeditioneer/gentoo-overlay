# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Media Manager for Kodi"
SRC_URI="https://github.com/Komet/MediaElch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="http://www.mediaelch.de/"
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="lto test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/quazip
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
	media-video/mediainfo"

S="${WORKDIR}/MediaElch-${PV}"

src_prepare() {
	if ! use test ; then
		sed -i \
			-e '/enable_testing()/d' \
			-e '/add_subdirectory(test)/d' \
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
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	dolib.so "${WORKDIR}/${P}_build/src/liblibmediaelch.so"
}
