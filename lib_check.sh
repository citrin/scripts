#!/bin/sh

# find binaries with missing libs
# they can appear after make -C /usr/src delete-old-libs

find /usr/local/bin/ /usr/local/sbin/ /usr/local/libexec/ -type f -print0 \
	| xargs -0 file --no-pad --separator ' ' \
	| awk '/dynamically linked/ { print $1 }' \
	| xargs ldd -f '%A: %o => %p\n' | fgrep 'not found'
