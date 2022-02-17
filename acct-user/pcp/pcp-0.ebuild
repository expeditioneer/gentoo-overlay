# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="User for pcp"
ACCT_USER_ID=755
ACCT_USER_GROUPS=( pcp )
ACCT_USER_HOME=/var/lib/pcp

acct-user_add_deps
