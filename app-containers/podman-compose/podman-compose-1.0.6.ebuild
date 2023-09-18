# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Run docker-compose files without root with podman"
HOMEPAGE="https://pypi.org/project/podman-compose https://github.com/containers/podman-compose"
SRC_URI="https://github.com/containers/podman-compose/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-containers/dnsname-cni-plugin
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		$(python_gen_any_dep 'dev-python/pytest[${PYTHON_USEDEP}]')
	)
"

python_test() {
	epytest ./pytests
}
