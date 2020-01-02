# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="User for cockpit web service"
ACCT_USER_ID=775
ACCT_USER_GROUPS=( cockpit-ws )
ACCT_USER_HOME=/var/lib/cockpit

acct-user_add_deps
