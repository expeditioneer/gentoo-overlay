#!/usr/bin/env bash

set -e

PORTAGE_UID=250
PORTAGE_GID=250

sudo groupadd --gid "${PORTAGE_GID}" portage

sudo useradd --uid "${PORTAGE_UID}" --gid "${PORTAGE_GID}" --user-group --home /var/tmp/portage --shell /bin/false portage

sudo usermod --append --groups portage travis
