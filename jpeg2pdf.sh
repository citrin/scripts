#!/bin/sh

# portmaster graphics/ImageMagick print/ghostscript9

if [ ! -r "$2" ]; then
        echo Usage: $0 merged.pdf page1.jpeg page2.jpeg ... pageN.jpeg
        exit 64
fi

outfile=$1
shift

param=""
toc=""
n=1
for f in "$@" ; do
	# PostScript point is 1/72 inch
	size=$(identify -format "%[fx:round(72 * w / resolution.x)] %[fx:round(72 * h / resolution.y)]" "${f}")
	param="$param <</PageSize [${size}]>> setpagedevice (${f}) viewJPEG showpage"
	toc="$toc [/Page $n /Title (File $f) /OUT pdfmark"
	n=$((n+1))
done

gs -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dQUIET \
	-o "$outfile" viewjpeg.ps -c "$toc" -c "$param"

# viewjpeg.ps is located in /usr/local/share/ghostscript/9.??/lib/viewjpeg.ps
# and this path should be in default search path (gs -h)
