# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
EGIT_COMMIT="18822f9a4fb35d1349eb256f4cd2bfd372474d84"
MY_PN=${PN//-cni-plugin}
MY_P=${MY_PN}-${PV}

inherit go-module

DESCRIPTION="dnsname plugin for podman"
HOMEPAGE="https://github.com/containers/dnsname"
SRC_URI="https://github.com/containers/dnsname/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

S="${WORKDIR}"/${MY_P}

DEPEND="
	app-containers/podman
	app-containers/cni-plugins
	net-dns/dnsmasq
"

RDEPEND="${DEPEND}"

src_prepare() {
	default
	local undesired_files=(
		CODE-OF-CONDUCT.md
		LICENSE
		OWNERS
		RELEASE_NOTES.md
	)

	rm -rv "${undesired_files[@]}" || die
}

src_compile() {
	local git_commit=${EGIT_COMMIT}
	export -n GOCACHE GOPATH XDG_CACHE_HOME
	GOBIN="${S}/bin" \
	emake all \
		GIT_BRANCH=master \
		GIT_BRANCH_CLEAN=master \
		COMMIT_NO="${git_commit}" \
		GIT_COMMIT="${git_commit}"
}

src_install() {
	exeinto /opt/cni/bin
	doexe bin/*
	dodoc README.md README_PODMAN.md SECURITY.md
}
