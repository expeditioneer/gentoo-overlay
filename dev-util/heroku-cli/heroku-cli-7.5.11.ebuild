# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="The Heroku CLI is used to manage Heroku apps from the command line"
HOMEPAGE="https://heroku.com"
SRC_URI="https://github.com/heroku/cli/archive/v${PV}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/ruby"

S="${WORKDIR}/cli-${PV}"

src_unpack() {
	unpack ${A}
}

src_install() {
	dodir "/usr/local/heroku"
	cp --recursive "${S}/${D}/usr/local/heroku/"
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
