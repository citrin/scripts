#!/bin/sh

PATH=/bin:/sbin:/usr/bin

if [ `id -u` -ne 0 ]; then
	echo 'You must be root to run this script'; echo;
	exit 1
fi

for d in $(sysctl -n kern.disks) ; do
	case $d in
		ad[0-9]*)
			model=$(atacontrol cap $d | sed -ne 's/^device model *//p')
		;;
		ada[0-9]*)
			model=$(camcontrol identify $d | sed -ne 's/^device model *//p')
		;;
		da[0-9]*)
			model=$(camcontrol inquiry $d | sed -n '1s/^.*<\(.*\)>.*$/\1/p')
		;;
	esac
	dd if=/dev/$d of=/dev/null bs=256k count=4096 2>&1 | \
		awk -v disk=$d -v model="$model" '/bytes transferred/ {printf "%5s: %6.2f Mb/s (%s)\n", disk, $1/$5/1024/1024, model}' &
done
wait
