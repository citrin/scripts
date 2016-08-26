#!/bin/sh

set -ex

# emerge media-gfx/imagemagick
# portmaster graphics/ImageMagick

for file in $@; do
	NAME=${file%.*}
	EXT=${file#$NAME.}

	width=`identify -format %w $file`

	new_width=$(($width / 2 + 100))

	# A4 size 210x297 (portland orient)
	new_height=$(( $new_width * 297 / 210 ))


	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthWest $NAME.$EXT $NAME-list1.png
	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthEast $NAME.$EXT $NAME-list2.png
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthWest $NAME.$EXT $NAME-list3.png
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthEast $NAME.$EXT $NAME-list4.png
done
