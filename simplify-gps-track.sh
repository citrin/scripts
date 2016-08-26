#!/bin/sh

# portmastr astro/gpsbabel

POINTS=400 # maximum number of points in resulting track

for i in $@; do
	file=`basename "$i"`
	name=${file%.*}

	if [ ! -f "$i" ]; then
		echo "$i: No such file"
		continue
	fi

	cd `dirname "$i"`

	case "$file" in
	*.gpx|*.gpx.gz)
		format=gpx
		;;
	*.kml)
		format=kml
		;;
	*.plt)
		format=ozi
		;;
	*)
		echo "$file: unknown track format"
		continue
	esac

	echo "try to convert $file to ${name}-small.gpx"
	gpsbabel -t -i $format -f "$file" -x track,pack,title="$name" -x simplify,count=${POINTS} -o gpx -F "${name}-small.gpx" && \
		echo "	done"
done
