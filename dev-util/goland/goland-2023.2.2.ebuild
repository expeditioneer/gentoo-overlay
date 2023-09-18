# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper xdg-utils

SLOT=0

SRC_URI="https://download.jetbrains.com/go/${P}.tar.gz"
DESCRIPTION="Golang IDE by JetBrains"
HOMEPAGE="https://www.jetbrains.com/go"

# JetBrains supports officially only x86_64 even though some 32bit binaries are
# provided. See https://www.jetbrains.com/go/download/#section=linux
KEYWORDS="~amd64"

LICENSE="|| ( JetBrains-business JetBrains-classroom JetBrains-educational JetBrains-individual )
	Apache-2.0
	BSD
	CC0-1.0
	CDDL
	CDDL-1.1
	EPL-1.0
	GPL-2
	GPL-2-with-classpath-exception
	ISC
	LGPL-2.1
	LGPL-3
	MIT
	MPL-1.1
	OFL
	ZLIB
"

RESTRICT="bindist mirror splitdebug"

QA_PREBUILT="opt/${P}/*"

S="${WORKDIR}/GoLand-${PV}"

RDEPEND="
	virtual/jdk
	dev-lang/go
"

src_prepare() {
    default
    local undesired_plugins=(
		help/ReferenceCardForMac.pdf
        plugins/cwm-plugin/quiche-native/darwin-aarch64
		plugins/cwm-plugin/quiche-native/darwin-x86-64
		plugins/cwm-plugin/quiche-native/linux-aarch64
		plugins/cwm-plugin/quiche-native/win32-x86-64
		plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-darwin-amd64
		plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-darwin-arm64
		plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-linux-arm64
		plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-windows-amd64.exe
		plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-windows-arm64.exe
		plugins/go-plugin/lib/dlv/linuxarm
		plugins/go-plugin/lib/dlv/mac
		plugins/go-plugin/lib/dlv/macarm
		plugins/go-plugin/lib/dlv/windows
		plugins/go-plugin/lib/dlv/windowsarm
	)

	rm -rv "${undesired_plugins[@]}" || die
}

src_install() {
	local dir="/opt/${P}"
	local JRE_DIR="jbr"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{${PN}.sh,format.sh,fsnotifier,inspect.sh,ltedit.sh,restart.py}

	fperms 755 "${dir}"/"${JRE_DIR}"/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/"${JRE_DIR}"/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.png" "${PN}.png"
	make_desktop_entry "${PN}" "goland" "${PN}" "Development;IDE;"
}

pkg_postinst() {
    echo
    elog "It is strongly recommended to increase the inotify watch limit"
    elog "to at least 524288. You can achieve this e.g. by calling"
    elog "echo \"fs.inotify.max_user_watches = 524288\" > /etc/sysctl.d/30-idea-inotify-watches.conf"
    elog "and reloading with \"sysctl --system\" (and restarting the IDE)."
    elog "For details see:"
    elog "    https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit"

	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
