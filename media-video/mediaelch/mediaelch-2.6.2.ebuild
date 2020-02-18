# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
inherit cmake-utils

DESCRIPTION="Video metadata scraper"
SRC_URI="https://github.com/Komet/MediaElch/archive/v${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="http://www.mediaelch.de/"
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="lto"

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

src_configure()
{
	local mycmakeargs=(
		-DUSE_EXTERN_QUAZIP=0N
		-DDISABLE_UPDATER=ON
		-DENABLE_LTO="$(usex lto)"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dolib.so "${WORKDIR}/${P}_build/src/liblibmediaelch.so"
}
