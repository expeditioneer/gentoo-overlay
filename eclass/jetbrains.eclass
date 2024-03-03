# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: jetbrains.eclass
# @MAINTAINER:
# expeditioneer@gentoo.org
# @SUPPORTED_EAPIS:8
# @BLURB: common ebuild functions for JetBrains products
# @DESCRIPTION:
# The jetbrains eclass makes creating ebuilds for JetBrains IDEs easier

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

inherit desktop

# @ECLASS_VARIABLE: UNDESIRED_FILES
# @DEFAULT_UNSET
# @PRE_INHERIT
# @DESCRIPTION:
# Bash string containing all files which should be removed

# @ECLASS_VARIABLE: FILES_REQUIRES_RPATH_ADAPTION
# @DEFAULT_UNSET
# @PRE_INHERIT
# @DESCRIPTION:
# Bash string containing all files where rpath should be set

QA_PREBUILT="opt/${PN}/*"

# @FUNCTION: _jetbrains_disable_automatic_updates
# @INTERNAL
# @DESCRIPTION:
# Internal function for removing automatic updates
_jetbrains_disable_automatic_updates() {
  	sed -i \
		-e "\$a\\\\" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$a# Disable automatic updates as these are handled through Gentoo's" \
		-e "\$a# package manager. See bug #704494" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$aide.no.platform.update=Gentoo" "${S}"/bin/idea.properties
}

# @FUNCTION: jetbrains_src_prepare
# @DESCRIPTION:
jetbrains_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"
  default_src_prepare

	_jetbrains_disable_automatic_updates

  for file in ${UNDESIRED_FILES}; do
    rm -rv "${S:?}/${file}" || die "Failed to remove ${file}"
  done

  for file in ${FILES_REQUIRES_RPATH_ADAPTION}; do
    patchelf --set-rpath '$ORIGIN' "${S:?}/${file}" || die "Failed to set rpath for ${file}"
	done
}
