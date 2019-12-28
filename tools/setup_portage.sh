#!/usr/bin/env bash

set -e

if [ -z "${PORTAGE_VERSION}" ]; then
  echo "PORTAGE_VERSION not set"
  exit 1
fi

echo -e "\e[33m Used Portage Version is: ${PORTAGE_VERSION}"

temporary_directory="$(mktemp --directory)"

gentoo_tree_dir="${PORTAGE_ROOT}/usr/portage"
portage_conf_dir="${PORTAGE_ROOT}/etc/portage"

DISTDIR="$(mktemp --directory)"

mkdir --parents "${PORTAGE_ROOT}/usr/lib64"
ln --symbolic lib64 "${PORTAGE_ROOT}/usr/lib"

portage_extracted_directory=${temporary_directory}/portage-archive
mkdir "${portage_extracted_directory}"
curl --location --silent "https://github.com/gentoo/portage/archive/portage-${PORTAGE_VERSION}.tar.gz" | tar --extract --gzip --directory="${portage_extracted_directory}" --strip-components=1

cd "${portage_extracted_directory}"

./setup.py install -O2 --system-prefix="${PORTAGE_ROOT}/usr" --sysconfdir="${PORTAGE_ROOT}/etc"
cp cnf/metadata.dtd "${DISTDIR}/"

mkdir --parents "${PORTAGE_ROOT}/usr/lib/portage/cnf/"
