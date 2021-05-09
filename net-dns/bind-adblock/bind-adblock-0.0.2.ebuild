# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd tmpfiles

DESCRIPTION="BIND DNS RPZ ad-blocker"
HOMEPAGE="https://github.com/expeditioneer/bind-adblock/"
SRC_URI="https://github.com/expeditioneer/bind-adblock/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE=""
RESTRICT=""

RDEPEND="
	acct-group/named
	acct-user/named
	dev-python/python-dateutil
	dev-python/dnspython
	dev-python/jinja
	dev-python/requests
	net-dns/bind
"

src_install() {
	keepdir /var/bind/rpz
	fowners root:named /var/bind/rpz
	fperms 0770 /var/bind/rpz
	dosym ../../var/bind/rpz /etc/bind/rpz

	insinto /etc/bind-adblock
	fowners named:named /etc/bind-adblock
	doins blocklists.conf
	fperms 0770 /etc/bind-adblock/blocklists.conf
	fowners root:named /etc/bind-adblock/blocklists.conf

	insinto /usr/bin
	doins update-blacklist-zonefile
	fowners root:named /usr/bin/update-blacklist-zonefile
	fperms 0750 /usr/bin/update-blacklist-zonefile

	insinto /usr/lib/bind-adblock/
	doins blocklist.zone.j2

	systemd_dounit "${S}/update-blacklist-zonefile.service"
	systemd_dounit "${S}/update-blacklist-zonefile.timer"
	newtmpfiles "${FILESDIR}"/${PN}-tmpfiles.d ${PN}.conf
}
