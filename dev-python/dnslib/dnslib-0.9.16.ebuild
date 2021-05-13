# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )

inherit distutils-r1

DESCRIPTION="Python IP address to Autonomous System Number lookup module"
HOMEPAGE="https://github.com/paulc/dnslib"
SRC_URI="https://github.com/paulc/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

python_test() {
	${EPYTHON} dnslib/bimap.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/bit.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/buffer.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/label.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/dns.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/lex.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/server.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/digparser.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/ranges.py - || die "tests failed under ${EPYTHON}"
	${EPYTHON} dnslib/test_decode.py || die "tests failed under ${EPYTHON}"
	${EPYTHON} fuzz.py || die "tests failed under ${EPYTHON}"
}
