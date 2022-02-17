# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="User for cockpit web service instance"
ACCT_USER_ID=776
ACCT_USER_GROUPS=( cockpit-wsinstance )
ACCT_USER_HOME=/var/lib/cockpit

acct-user_add_deps
