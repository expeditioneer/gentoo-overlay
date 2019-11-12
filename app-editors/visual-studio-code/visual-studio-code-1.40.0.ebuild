# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop eutils pax-utils

DESCRIPTION="Multiplatform Visual Studio Code from Microsoft"
HOMEPAGE="https://code.visualstudio.com"
LICENSE="MIT"

SRC_URI="https://vscode-update.azurewebsites.net/${PV}/linux-x64/stable -> ${P}-amd64.tar.gz"

RESTRICT="bindist mirror strip"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
		media-libs/libpng:0
		>=x11-libs/gtk+-2.24.8-r1:2
		x11-libs/cairo
		gnome-base/gconf
		x11-libs/libXtst
"

RDEPEND="
		${DEPEND}
		>=net-print/cups-2.0.0
		x11-libs/libnotify
		x11-libs/libXScrnSaver
		app-crypt/libsecret[crypt]
"

QA_PRESTRIPPED="opt/${PN}/code"
QA_PREBUILT="opt/${PN}/code"
S="${WORKDIR}/VSCode-linux-x64"

src_install(){
		pax-mark m code
		insinto "/opt/${PN}"
		doins -r *
		dosym "${EPREFIX}/opt/${PN}/bin/code" "/usr/bin/${PN}"

		make_desktop_entry "${PN}" "Visual Studio Code" "${PN}" "Development;IDE"
		doicon "${FILESDIR}"/"${PN}".png

		fperms +x "/opt/${PN}/code"
		fperms +x "/opt/${PN}/bin/code"
		#fperms +x "/opt/${PN}/libnode.so"
		fperms +x "/opt/${PN}/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/rg"

		insinto "/usr/share/licenses/${PN}"
		newins "resources/app/LICENSE.rtf" "LICENSE"
}

pkg_postinst(){
		elog "You may install some additional utils, so check them in:"
		elog "https://code.visualstudio.com/docs/setup/additional-components"
}
