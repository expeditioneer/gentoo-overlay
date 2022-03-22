# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="389-ds-base"

DESCRIPTION="389-ds management plugin for cockpit"
HOMEPAGE="https://directory.fedoraproject.org/"
SRC_URI="https://github.com/389ds/${MY_PN}/archive/refs/tags/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-3+ Apache-2.0 BSD MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="sys-apps/cockpit"
BDEPEND="net-libs/nodejs[npm]"

S="${WORKDIR}/${MY_PN}-${MY_PN}-${PV}/src/cockpit/389-console"

src_prepare() {
	default
	sed -i -e 's /usr/bin/echo /bin/echo g' "${S}/src/dsModals.jsx" || die

	sed -i -e 's#The version of the Directory Server rpm package#The version of the Directory Server#g' "${S}/src/lib/server/settings.jsx" || die

	npm install package.json
}

src_compile() {
	node_modules/webpack/bin/webpack.js
}

src_install() {
	dodir /usr/share/cockpit/389-console
	cp -r "${S}"/dist/* "${ED}"/usr/share/cockpit/389-console || die
}