#!/usr/bin/env bash

PORTAGE_UID=250
PORTAGE_GID=250

useradd -uid "${PORTAGE_UID}"  --gid "${PORTAGE_GID}" --user-group --home /var/tmp/portage --shell /bin/false portage

usermod --append --groups portage travis
