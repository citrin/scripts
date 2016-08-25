#!/bin/sh

# to rebuild stale gmirror components after reboot
# add to root cron:
#
# @reboot	sleep 7753 && /usr/local/sbin/gmirror-rebuild.sh

set -e

PATH=/bin:/sbin:/usr/bin

if [ `id -u` -ne 0 ]; then
	echo 'You must be root to run this script'; echo;
	exit 1
fi

if [ ! -d /dev/mirror ]; then
	echo 'no gmirror found'
	exit
fi

for mirror in `gmirror status -gs | awk '{print $1}' | uniq`; do
	gmirror status -s $mirror | awk '$4 == "(STALE)" {print $3}' | xargs gmirror rebuild $mirror
	sleep 71
done
