# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib virtualx

DESCRIPTION="GTK+ version of wxWidgets, a cross-platform C++ GUI toolkit"
HOMEPAGE="https://wxwidgets.org/"
SRC_URI="
	https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}.tar.bz2
	doc? ( https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}-docs-html.tar.bz2 )"

LICENSE="wxWinLL-3 GPL-2 doc? ( wxWinFDL-3 )"

KEYWORDS="~amd64"
SLOT="$(ver_cut 1-2)/${PV}"
IUSE="doc debug gstreamer libnotify opengl sdl test tiff webkit +X"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/expat[${MULTILIB_USEDEP}]
	sdl? ( media-libs/libsdl[${MULTILIB_USEDEP}] )
	X? (
		>=dev-libs/glib-2.22:2[${MULTILIB_USEDEP}]
		media-libs/libpng:0=[${MULTILIB_USEDEP}]
		sys-libs/zlib[${MULTILIB_USEDEP}]
		virtual/jpeg:0=[${MULTILIB_USEDEP}]
		x11-libs/cairo[${MULTILIB_USEDEP}]
		x11-libs/gtk+:3[${MULTILIB_USEDEP}]
		x11-libs/gdk-pixbuf[${MULTILIB_USEDEP}]
		x11-libs/libSM[${MULTILIB_USEDEP}]
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
		x11-libs/pango[${MULTILIB_USEDEP}]
		gstreamer? (
			media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
			media-libs/gst-plugins-base:1.0[${MULTILIB_USEDEP}] )
		libnotify? ( x11-libs/libnotify[${MULTILIB_USEDEP}] )
		opengl? ( virtual/opengl[${MULTILIB_USEDEP}] )
		tiff?   ( media-libs/tiff:0[${MULTILIB_USEDEP}] )
		webkit? ( net-libs/webkit-gtk:4 )
		)
"
# TODO: further dependencies
#Package 'gnome-vfs-2.0', required by 'virtual:world', not found
#-- libgnomevfs not found, library won't be used to associate MIME type
# Could NOT find PCRE2 (missing: PCRE2_LIBRARIES) (found version "")
# wxUSE_NANOSVG:    builtin  (use NanoSVG for rasterizing SVG)
# wxUSE_REGEX:      builtin  (enable support for wxRegEx class)

DEPEND="${RDEPEND}
	opengl? ( virtual/glu[${MULTILIB_USEDEP}] )
	X? ( x11-base/xorg-proto )"

PDEPEND=">=app-eselect/eselect-wxwidgets-20131230"

S="${WORKDIR}/wxWidgets-${PV}"

PATCHES=(
	"${FILESDIR}/${P}-no-prestrip.patch"
	"${FILESDIR}/${P}-gcc-werror.patch"
	"${FILESDIR}/wxGTK-$(ver_cut 1-2)-slotting.patch"
)

multilib_src_configure() {

	CMAKE_BUILD_TYPE="Release"

	# wxDEBUG_LEVEL=1 is the default and we will leave it enabled
	# wxDEBUG_LEVEL=2 enables assertions that have expensive runtime costs.
	# apps can disable these features by building w/ -NDEBUG or wxDEBUG_LEVEL_0.
	# https://docs.wxwidgets.org/3.1/overview_debugging.html
	local mycmakeargs=(
		-DwxBUILD_DEBUG_LEVEL=$(usex debug 2 1)
		-DwxBUILD_TESTS=$(usex test ALL OFF)
		-Wno-dev
	)
	cmake_src_configure
}

multilib_src_install_all() {
	cd "${S}"/docs || die
	dodoc changes.txt readme.txt
	newdoc base/readme.txt base_readme.txt
	newdoc gtk/readme.txt gtk_readme.txt

	use doc && HTML_DOCS="${WORKDIR}"/wxWidgets-${PV}-docs-html/.
	einstalldocs
}

src_test() {
	virtx default
}

pkg_postinst() {
	has_version app-eselect/eselect-wxwidgets \
		&& eselect wxwidgets update
}

pkg_postrm() {
	has_version app-eselect/eselect-wxwidgets \
		&& eselect wxwidgets update
}
