#!/bin/sh

# emerge media-sound/mp3splt media-sound/lame
# portmaster audio/mp3splt audio/lame audio/flac audio/wavpack

# -V n   0 <= n <= 9
# Enable  VBR  (Variable  BitRate)  and specifies the value of VBR
# quality (default = 4).  0 = highest quality.

: ${QUALITY=3}

set -ex

if [ ! -r "$1" ]; then
	echo Usage: $0 file.flac
	exit 64
fi

FILE=`basename "$1"`
NAME=${FILE%.*}
cd `dirname "$1"`

LAME="lame -s 44.1 --vbr-new -V $QUALITY -B 320"

case $FILE in
	*.ape)
		CUE="${NAME}.cue"
		iconv -f cp1251 -t utf-8 < "$CUE" > "${CUE}.utf"
		CUE="${CUE}.utf"
		mac.exe "$FILE" "${NAME}.wav" -d
		$LAME "${NAME}.wav" "${NAME}.mp3"
		rm "${NAME}.wav"
		;;
	*.flac)
		# find .cue file
		if [ -f "${FILE}.cue" ]; then
			CUE="${FILE}.cue"
		elif [ -f "${NAME}.cue" ]; then
			CUE="${NAME}.cue"
		else
			echo "Can't find .cue file"
			exit 64
		fi
		iconv -f cp1251 -t utf-8 < "$CUE" > "${CUE}.utf"
		CUE="${CUE}.utf"
		flac -c -d "$FILE" | $LAME - "${NAME}.mp3"
		;;
	*.wv)
		CUE="${NAME}.cue"
		wvunpack --no-utf8-convert -c "${FILE}" > $CUE
		wvunpack "${FILE}" -o - | $LAME - "${NAME}.mp3"
		;;
	*.wav)
		CUE="${NAME}.cue"
		iconv -f cp1251 -t utf-8 < "${NAME}.cue" > "${NAME}.cue.utf"
		CUE="${NAME}.cue.utf"
		$LAME "$FILE" "${NAME}.mp3"
		;;
	*)
		echo unsupported format
		exit 1
	esac

renice -n +15 -p $$ 2>/dev/null

mp3splt -f -T2 -a -c "$CUE" -o "@n @a - @t" "${NAME}.mp3"
rm "${NAME}.mp3"
