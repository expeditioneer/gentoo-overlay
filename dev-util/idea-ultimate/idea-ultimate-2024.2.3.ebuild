# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# LLDBFrontEnd after licensing questions with Gentoo License Team
UNDESIRED_FILES="
	lib/async-profiler/aarch64
	lib/pty4j
	plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-linux-arm64
	plugins/Kotlin/bin/linux/LLDBFrontend
	plugins/maven/lib/maven3/lib/jansi-native/Windows
	plugins/platform-ijent-impl/ijent-aarch64-unknown-linux-musl-release
"

FILES_REQUIRES_RPATH_ADAPTION="
	jbr/lib/jcef_helper
	jbr/lib/libjcef.so
"

inherit desktop jetbrains wrapper

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/idea"
SRC_URI="https://download-cdn.jetbrains.com/idea/ideaIU-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/idea-IC-${PV}"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CDDL-1.1
	codehaus-classworlds CPL-1.0 EPL-1.0 EPL-2.0
	GPL-2 GPL-2-with-classpath-exception ISC
	JDOM LGPL-2.1 LGPL-2.1+ LGPL-3-with-linking-exception MIT
	MPL-1.0 MPL-1.1 OFL-1.1 ZLIB"

SLOT="0"

KEYWORDS="~amd64"

DEPEND="
	|| (
		>=dev-java/openjdk-17.0.6_p10:17
		>=dev-java/openjdk-bin-17.0.6_p10:17
	)"

RDEPEND="${DEPEND}
	app-accessibility/at-spi2-core
	dev-util/jetbrains-common
	dev-java/jansi-native
	dev-libs/libdbusmenu
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/mesa
	net-print/cups
	sys-libs/glibc
	sys-libs/zlib
	x11-libs/libXi
	x11-libs/libXtst
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libxkbcommon
	x11-libs/libXrender
	x11-libs/pango"

QA_PREBUILT="opt/${PN}/*"

src_unpack() {

	default_src_unpack
	if [ ! -d "$S" ]; then
		einfo "Renaming source directory to predictable name..."
		mv $(ls "${WORKDIR}") "idea-IC-${PV}" || die
	fi
}

src_prepare() {
	jetbrains_src_prepare
	eapply_user
}

src_install() {
	local dir="/opt/${PN}"
	local dst="${D}${dir}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{format.sh,idea.sh,inspect.sh,fsnotifier}

	fperms 755 "${dir}"/jbr/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,jwebserver,keytool,rmiregistry,serialver}

	# Fix #763582
	fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	if use amd64; then
		JRE_DIR=jre64
	else
		JRE_DIR=jre
	fi

	JRE_BINARIES="jaotc java javapackager jjs jrunscript keytool pack200 rmid rmiregistry unpack200"
	if [[ -d ${JRE_DIR} ]]; then
		for jrebin in $JRE_BINARIES; do
			fperms 755 "${dir}"/"${JRE_DIR}"/bin/"${jrebin}"
		done
	fi

	# bundled script is always lowercase, and doesn't have -ultimate, -professional suffix.
	local bundled_script_name="${PN%-*}.sh"
	make_wrapper "${PN}" "${dir}/bin/$bundled_script_name" || die

	local pngfile="$(find ${dst}/bin -maxdepth 1 -iname '*.png')"
	newicon $pngfile "${PN}.png" || die "we died"

	make_desktop_entry "${PN}" "IntelliJ Idea Professional Edition" "${PN}" "Development;IDE;"

	# remove bundled harfbuzz
	rm -f "${D}"/lib/libharfbuzz.so || die "Unable to remove bundled harfbuzz"
}
