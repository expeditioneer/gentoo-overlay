# expeditioneer's Gentoo overlay 

[![Build Status](https://travis-ci.org/expeditioneer/gentoo-overlay.svg?branch=master)](https://travis-ci.org/expeditioneer/gentoo-overlay)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/expeditioneer/gentoo-overlay/graphs/commit-activity)
[![Open Source Love svg2](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

## Using with Portage
Create a new config file under `/etc/portage/repos.conf/expeditioneer.conf` with the following contents:

	[expeditioneer]
	auto-sync = yes
	location = /usr/local/portage/overlays/expeditioneer
	sync-type = git
	sync-uri = https://github.com/expeditioneer/gentoo-overlay.git

You may adapt the `location` attribute to your system's own setup.

# Bug reports and ebuild requests

If you find a bug in an ebuild, encounter a build error or would like me to add a new ebuild, please open an issue on [GitHub](https://github.com/expeditioneer/gentoo-overlay/issues).

## Contributing

I gladly accept pull requests for bugs or new ebuilds. Before opening a pull request, please make sure your changes don't upset [`repoman`](https://wiki.gentoo.org/wiki/Repoman). Run the following command and fix warnings and errors:

	repoman -x -p

## Acknowledgements

Thanks go to Jakub Jirutka, the maintainer of the [CVUT Overlay](https://github.com/cvut/gentoo-overlay), from whom I shamelessly copied this README.md for a start.

