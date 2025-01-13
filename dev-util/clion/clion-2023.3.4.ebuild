# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UNDESIRED_FILES="
	bin/cmake
	bin/gdb/linux
	bin/lldb/linux
	bin/ninja
	help/ReferenceCardForMac.pdf
	lib/async-profiler/aarch64
	plugins/cwm-plugin/quiche-native/darwin-aarch64
	plugins/cwm-plugin/quiche-native/darwin-x86-64
	plugins/cwm-plugin/quiche-native/linux-aarch64
	plugins/cwm-plugin/quiche-native/win32-x86-64
	plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-linux-arm64
	plugins/platform-ijent-impl/ijent-x86_64-unknown-linux-musl-release
	plugins/python-ce/helpers/pydev/pydevd_attach_to_process/attach_linux_aarch64.so
	plugins/remote-dev-server/selfcontained
"

FILES_REQUIRES_RPATH_ADAPTION="
	jbr/lib/libjcef.so
	jbr/lib/jcef_helper
	bin/clang/linux/x64/libclazyPlugin.so
	bin/clang/linux/x64/libclazyPlugin.so.18git
"

inherit desktop jetbrains wrapper xdg-utils

DESCRIPTION="A complete toolset for C and C++ development"
HOMEPAGE="https://www.jetbrains.com/clion/"
SRC_URI="https://download.jetbrains.com/cpp/CLion-${PV}.tar.gz"

LICENSE="|| ( IDEA IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1 CPL-0.5 CPL-1.0
	EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC JDOM
	LGPL-2.1+ LGPL-3 MIT MPL-1.0 MPL-1.1 OFL public-domain PSF-2 UoI-NCSA ZLIB"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror splitdebug"

BDEPEND="dev-util/patchelf"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-alternatives/ninja
	dev-build/cmake
	dev-debug/gdb
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	dev-util/jetbrains-common
	media-libs/alsa-lib
	media-libs/freetype:2
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango"

src_prepare() {
	jetbrains_src_prepare
}

src_install() {
	local dir="/opt/${PN}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{clion.sh,fsnotifier,inspect.sh,ltedit.sh,repair,restarter,clang/linux/x64/{clangd,clang-tidy,clazy-standalone,llvm-symbolizer}}

	if [[ -d jbr ]]; then
		fperms 755 "${dir}"/jbr/bin/{java,javac,jdb,jrunscript,keytool,rmiregistry,serialver}
		# Fix #763582
		fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}
	fi

	dosym -r "${EPREFIX}/usr/bin/ninja" "${dir}"/bin/ninja/linux/x64/ninja

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "CLion" "${PN}" "Development;IDE;"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
