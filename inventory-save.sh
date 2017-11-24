#!/bin/sh

set -e

PATH=/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

cd /var/db/inventory || exit 1

if kldstat -q -m g_mirror; then
	gmirror status -s | sort > gmirror.txt
elif [ -f gmirror.txt ]; then
	rm gmirror.txt
fi

if [ -c /dev/zfs ]; then
	zpool status | grep -Fv 'scan:' > zpool.txt
elif [ -f zpool.txt ]; then
	rm zpool.txt
fi

if [ $(id -u) -ne 0 ]; then
	SUDO=sudo
else
	SUDO=''
fi

$SUDO dmidecode --quiet > dmidecode.txt

rm -f disk_*.txt

for d in $(sysctl -n kern.disks); do
	case $d in
	# skip removable devices
	cd[0-9] | mmcsd[0-9] )
		;;
	* )
		disk_list="$disk_list $d"
		;;
	esac
done

for d in $disk_list; do
	$SUDO smartctl --info /dev/${d} | awk 'NR > 3 && ! /Local Time/' > disk_${d}.txt
done
