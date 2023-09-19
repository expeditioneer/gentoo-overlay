# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SLOT=0

S=${WORKDIR}

DESCRIPTION="Common configuration for all JetBrains IDEs"
HOMEPAGE="https://www.jetbrains.com/"
LICENSE="GPL-3"

src_install() {
	insinto /etc/sysctl.d/
	doins "${FILESDIR}/30-jetbrains-inotify-watches.conf"
}

pkg_postinst() {
	sysctl --load=/etc/sysctl.d/30-jetbrains-inotify-watches.conf
}
