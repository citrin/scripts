#!/bin/sh

# emerge media-gfx/imagemagick media-libs/exiftool
# portmaster graphics/ImageMagick graphics/p5-Image-ExifTool

# Script to resize (shrink) images:
# landscape to be 768 px height
# portrait to be 1024 px width

set -e

new_height=768
new_width=1024
cmd='convert -resize'

for i in $*; do
	ext=${i##*.}
	if [ ! -f $i -o "$ext" != 'jpg' -a "$ext" != 'jpeg' ]; then
		echo "skip $i"
		continue
	fi

	cd `dirname $i`

	width=`identify -format %w $i`
	height=`identify -format %h $i`

	if [ $width -gt $height ]; then
		# landscape orient
		if [ $height -le $new_height ]; then
			echo "already small: ${width}x${height}, skip"
			continue
		fi
		$cmd x$new_height $i tmp_$i
	else
		# portrait orient
		if [ $height -le $new_width ]; then
			echo "already small: ${width}x${height}, skip"
			continue
		fi
		$cmd $new_width $i tmp_$i
	fi

	mv -v tmp_$i $i
	exiftool -overwrite_original -Software= $i
done
