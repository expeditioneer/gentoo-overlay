# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit distutils-r1

DESCRIPTION="Pure-Python Reed Solomon encoder/decoder"
HOMEPAGE="https://github.com/theneweinstein/pysomneo https://github.com/theneweinstein/pysomneo"
SRC_URI="https://github.com/theneweinstein/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 x86"

RDEPEND="
  >=dev-python/requests-2.24.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26.5[${PYTHON_USEDEP}]
"
