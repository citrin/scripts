#!/bin/sh

set -ex

# emerge media-gfx/imagemagick
# portmaster graphics/ImageMagick

for file in "$@"; do
	width=`identify -format %w "${file}"`

	# 100 pixels is overlap between lists
	new_width=$(( $width / 2 + 100))

	# A4 size 210x297 (portrait oriented)
	new_height=$(( $new_width * 297 / 210 ))

	name=${file%.*}

	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthWest "${file}" "${name}-list1.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity NorthEast "${file}" "${name}-list2.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthWest "${file}" "${name}-list3.png"
	convert -crop ${new_width}x${new_height}+0+0 -gravity SouthEast "${file}" "${name}-list4.png"
done
