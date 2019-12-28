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
cd "${portage_extracted_directory}/repoman"
./setup.py install -O2 --system-prefix="${PORTAGE_ROOT}/usr" --sysconfdir="${PORTAGE_ROOT}/etc"
sudo mkdir --parents /usr/share/repoman/qa_data
sudo cp "${portage_extracted_directory}/repoman/cnf/qa_data/qa_data.yaml" /usr/share/repoman/qa_data/

rm --recursive --force "${temporary_directory}"
mkdir --parents "${PORTAGE_ROOT}/usr/lib/portage/"

mkdir --parents "${gentoo_tree_dir}"
curl --location --silent "https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz" | tar --extract --gzip --directory="${gentoo_tree_dir}" --strip-components=1


mkdir -p "${portage_conf_dir}/repos.conf"
cat > "${portage_conf_dir}/repos.conf/repos" << _EOF_
[DEFAULT]
main-repo = gentoo

[gentoo]
location = ${gentoo_tree_dir}

[expeditioneer]
location = ${TRAVIS_BUILD_DIR}
_EOF_

cat > "${portage_conf_dir}/make.conf" << _EOF_
PORTAGE_TMPDIR="$(mktemp --directory)"
PKGDIR="$(mktemp --directory)"
DISTDIR="$(mktemp --directory)"
RPMDIR="$(mktemp --directory)"
_EOF_

ln --symbolic "${gentoo_tree_dir}/profiles/default/linux/${TRAVIS_CPU_ARCH}/17.1" /etc/portage/make.profile

