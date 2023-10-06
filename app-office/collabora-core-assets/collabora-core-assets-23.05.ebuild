# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Collabora Core Assets"
HOMEPAGE="https://collaboraonline.github.io/"
SRC_URI="
	https://github.com/CollaboraOnline/online/releases/download/for-code-assets/core-co-${PV}-assets.tar.gz
		-> ${P}-assets.gh.tar.gz
"

LICENSE="MPL-2.0"

SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/coolwsd/libreoffice
	doins -r instdir/*
	insinto /usr/share/coolwsd/libreoffice-kit
	doins -r include/*
}
