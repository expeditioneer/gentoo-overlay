# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils wrapper

MY_PN=${PN/-professional/}
DESCRIPTION="Intelligent Python IDE with unique code assistance and analysis"
HOMEPAGE="https://www.jetbrains.com/pycharm/"
SRC_URI="https://download.jetbrains.com/python/${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="PyCharm_Academic PyCharm_Classroom PyCharm PyCharm_OpenSource PyCharm_Preview"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+bundled-jdk"
RESTRICT="bindist mirror splitdebug"

RDEPEND="!bundled-jdk? ( >=virtual/jre-1.8 )
	app-arch/brotli
	app-arch/zstd
	app-crypt/p11-kit
	dev-libs/fribidi
	dev-libs/glib
	dev-libs/json-c
	dev-libs/libbsd
	dev-libs/libdbusmenu
	dev-libs/nss
	dev-python/pip
	media-fonts/dejavu
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype:2=
	media-libs/harfbuzz
	media-libs/libglvnd
	media-libs/libjpeg-turbo:0=
	media-libs/libpng:0=
	net-libs/gnutls
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango
"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="opt/${PN}/*"

src_prepare() {
	default
	local remove_me=(
		help/ReferenceCardForMac.pdf
		lib/pty4j-native/linux/aarch64
		lib/pty4j-native/linux/arm
		lib/pty4j-native/linux/mips64el
		lib/pty4j-native/linux/ppc64le
		lib/pty4j-native/linux/$(usex amd64 x86 x86_64)
		plugins/remote-dev-server/selfcontained
		plugins/performanceTesting/bin/libyjpagent.so
		plugins/performanceTesting/bin/*.dll
		plugins/performanceTesting/bin/libyjpagent.dylib
		plugins/python/helpers/pydev/pydevd_attach_to_process/attach_linux_x86.so
		plugins/python/helpers/pydev/pydevd_attach_to_process/attach_linux_amd64.so
		plugins/wsl-fs-helper
	)

	rm -rv "${remove_me[@]}" || die

	sed -i \
		-e "\$a\\\\" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$a# Disable automatic updates as these are handled through Gentoo's" \
		-e "\$a# package manager. See bug #704494" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$aide.no.platform.update=Gentoo" \
		bin/idea.properties || die

	local file
	for file in jbr/lib/{libjcef.so,jcef_helper}; do
		if [[ -f ${file} ]]; then
			patchelf --set-rpath '$ORIGIN' ${file} || die
		fi
	done
}

src_install() {
	local dir="/opt/${PN}"
	local jre_dir="jbr"

	insinto ${dir}
	doins -r *

	if ! use bundled-jdk; then
		rm -r "${jre_dir}" || die
	fi

	fperms 755 "${dir}"/bin/{format.sh,fsnotifier,inspect.sh,ltedit.sh,pycharm.sh,restart.py}

	fperms 755 "${dir}"/"${jre_dir}"/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/"${jre_dir}"/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	make_wrapper "${PN}" "${DIR}/bin/pycharm.sh"
	newicon bin/${MY_PN}.png ${PN}.png
	make_desktop_entry ${PN} ${PN} ${PN}

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /etc/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf" || die
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
