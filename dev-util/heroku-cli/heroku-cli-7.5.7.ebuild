# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Client tools for heroku"
HOMEPAGE="http://heroku.com"
SRC_URI="https://cli-assets.heroku.com/heroku-v${PV}/heroku-v${PV}-win32-x64.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/ruby"

S="${WORKDIR}/heroku"

src_unpack() {
	unpack ${A}
}

src_install() {
	dodir "/usr/local/heroku"
	cp --recursive "${S}"/ "${D}"/usr/local/heroku/
	dodir "/usr/local/bin"
	dosym ../heroku/bin/heroku /usr/local/bin/heroku
}

pkg_postinst() {
	einfo "To start using heroku, please create first an account at"
	einfo "${HOMEPAGE}, then run"
	einfo " \$ heroku login"
	einfo "this will ask for your login data and generate a public ssh key"
	einfo "for you if needed. To deploy your app do:"
	einfo " \$ cd ~/myapp"
	einfo " \$ heroku create"
}
