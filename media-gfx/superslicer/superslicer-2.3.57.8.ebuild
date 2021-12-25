# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.1"

inherit xdg cmake desktop wxwidgets

MY_PN="SuperSlicer"

DESCRIPTION="A mesh slicer to generate G-code for fused-filament-fabrication (3D printers)"
HOMEPAGE="https://github.com/supermerill/SuperSlicer"
SRC_URI="https://github.com/supermerill/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3 Boost-1.0 GPL-2 LGPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/eigen:3
	>=dev-cpp/tbb-2021.4.0
	>=dev-libs/boost-1.73.0:=[nls,threads(+)]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	>=dev-libs/miniz-2.1.0-r2
	dev-libs/mpfr:=
	>=media-gfx/openvdb-5.0.0
  media-libs/glew:0=
	media-libs/ilmbase:=
	media-libs/libpng:0=
	media-libs/qhull:=
	net-misc/curl
	sci-libs/libigl
	sci-libs/nlopt
	>=sci-mathematics/cgal-5.0:=
	sys-apps/dbus
	sys-libs/zlib:=
	virtual/glu
	virtual/opengl
	x11-libs/gtk+:3
	x11-libs/wxGTK:${WX_GTK_VER}[X,opengl]
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
"

S="${WORKDIR}/${MY_PN}-${PV}"

PATCHES=(
	"${FILESDIR}/${P}-boost.patch"
	"${FILESDIR}/${P}-minizip-zip-header.patch"
	"${FILESDIR}/${P}-tbb-2021.patch"
	"${FILESDIR}/${P}-wxgtk.patch"
)

src_prepare() {
	cp "${FILESDIR}/FindTBB.cmake" "${S}/cmake/modules/FindTBB.cmake" || die

	sed -i -e 's/${SLIC3R_APP_KEY}-${SLIC3R_VERSION}+UNKNOWN/${SLIC3R_APP_KEY}-${SLIC3R_VERSION}+Gentoo/g' version.inc || die
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	local mycmakeargs=(
		-DSLIC3R_BUILD_TESTS=$(usex test)
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=ON
		-DSLIC3R_PCH=OFF
		-SLIC3R_STATIC=OFF
		-DSLIC3R_WX_STABLE=OFF
		-Wno-dev
	)

	cmake_src_configure
}
