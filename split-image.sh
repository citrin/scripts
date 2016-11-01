#!/bin/sh

set -ex

# emerge media-gfx/imagemagick
# portmaster graphics/ImageMagick

for file in "$@"; do
	NAME=${file%.*}
	EXT=${file#$NAME.}

	width=`identify -format %w "${file}"`

	# 100 is overlap between lists
	new_width=$(( $width / 2 + 100))

	# A4 size 210x297 (portrait oriented)
	new_height=$(( $new_width * 297 / 210 ))

	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthWest "${file}" "${NAME}-list1.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthEast "${file}" "${NAME}-list2.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthWest "${file}" "${NAME}-list3.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthEast "${file}" "${NAME}-list4.png"
done
