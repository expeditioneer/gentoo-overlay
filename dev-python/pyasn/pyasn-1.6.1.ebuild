# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )

inherit distutils-r1

MY_PV="${PV}-re"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Python IP address to Autonomous System Number lookup module"
HOMEPAGE="https://github.com/hadiasghari/pyasn"
SRC_URI="https://github.com/hadiasghari/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE=""

RDEPEND="virtual/python-ipaddress[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
    dev-python/setuptools[${PYTHON_USEDEP}]"

S=${WORKDIR}/${MY_P}
