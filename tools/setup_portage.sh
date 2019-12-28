#!/usr/bin/env bash

set -e


if [ -z "${PORTAGE_ROOT}" ]; then
  echo "PORTAGE_ROOT not set"
  exit 1
fi

if [ -z "${PORTAGE_VERSION}" ]; then
  echo "PORTAGE_VERSION not set"
  exit 1
fi

echo -e "\e[33m Used Portage version is: ${PORTAGE_VERSION}"

temporary_directory="$(mktemp --directory)"

gentoo_tree_dir="${PORTAGE_ROOT}/usr/portage"
portage_conf_dir="${PORTAGE_ROOT}/etc/portage"

mkdir --parents "${PORTAGE_ROOT}/usr/lib64"
ln --symbolic lib64 "${PORTAGE_ROOT}/usr/lib"

portage_extracted_directory=${temporary_directory}/portage-archive
mkdir "${portage_extracted_directory}"
curl --location --silent "https://github.com/gentoo/portage/archive/portage-${PORTAGE_VERSION}.tar.gz" | tar --extract --gzip --directory="${portage_extracted_directory}" --strip-components=1

cd "${portage_extracted_directory}"
./setup.py install -O2 --system-prefix="${PORTAGE_ROOT}/usr" --sysconfdir="${PORTAGE_ROOT}/etc"
mkdir --parents "${PORTAGE_ROOT}/usr/lib/portage/cnf/"

mkdir --parents "${gentoo_tree_dir}"
curl --location --silent "https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz" | tar --extract --gzip --directory="${gentoo_tree_dir}" --strip-components=1


mkdir -p "${portage_conf_dir}/repos.conf"
cat > "${portage_conf_dir}/repos.conf/repos" << _EOF_
[DEFAULT]
main-repo = gentoo

[gentoo]
location = ${gentoo_tree_dir}

[${TRAVIS_REPO_SLUG} | cut --delimiter='/' --fields=1 ]
location = ${TRAVIS_BUILD_DIR}
_EOF_

cat "${portage_conf_dir}/repos.conf/repos"

cat > "${portage_conf_dir}/make.conf" << _EOF_
DISTDIR="$(mktemp --directory)"
PKGDIR="$(mktemp --directory)"
PORTAGE_TMPDIR="$(mktemp --directory)"
RPMDIR="$(mktemp --directory)"
_EOF_

cat "${portage_conf_dir}/make.conf"

ln --symbolic "${gentoo_tree_dir}/profiles/base" "${portage_conf_dir}/make.profile"

rm --recursive --force "${temporary_directory}"