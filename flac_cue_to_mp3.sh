#!/bin/sh

# emerge media-sound/mp3splt media-sound/lame
# portmaster audio/mp3splt audio/lame audio/flac audio/wavpack audio/mp3gain

# -V n   0 <= n <= 9
# Enable  VBR  (Variable  BitRate)  and specifies the value of VBR
# quality (default = 4).  0 = highest quality.

: ${QUALITY=2}
: ${CUE_ENCODING=latin1}

set -ex

if [ ! -r "$1" ]; then
	echo Usage: $0 file.flac
	exit 64
fi

FILE=`basename "$1"`
NAME=${FILE%.*}
DIR=`dirname "$1"`
cd "${DIR}"
renice -n +15 -p $$ 2>/dev/null

LAME="lame --noreplaygain --vbr-new -V $QUALITY"

# find .cue file for all types exept .wv (contains embedded CUE)
if [ "${FILE##*.}" = "wv" ]; then
	CUE="${NAME}.cue"
else
	# find .cue file and convert it to UTF
	if [ -e "${FILE}.cue" ]; then
		CUE="${FILE}.cue"
	elif [ -e "${NAME}.cue" ]; then
		CUE="${NAME}.cue"
	else
		echo "Can't find .cue file"
		exit 64
	fi

	iconv -f $CUE_ENCODING -t utf-8 < "$CUE" > "${CUE}.utf"
	CUE="${CUE}.utf"
fi

case $FILE in
	*.ape)
		mac.exe "$FILE" "${NAME}.wav" -d
		$LAME "${NAME}.wav" "${NAME}.mp3"
		rm "${NAME}.wav"
		;;
	*.flac)
		flac -c -d "$FILE" | $LAME - "${NAME}.mp3"
		;;
	*.wv)
		wvunpack --no-utf8-convert -c "${FILE}" > "${CUE}"
		wvunpack "${FILE}" -o - | $LAME - "${NAME}.mp3"
		;;
	*.wav)
		$LAME "$FILE" "${NAME}.mp3"
		;;
	*)
		echo unsupported format
		exit 1
	esac

if [ $CUE_ENCODING = latin1 ]; then
	TAG_VER=12
	ID3V2_ENC=1  # latin1
else
	TAG_VER=2
	ID3V2_ENC=16 # UTF-16
fi

# file name format
# @N2 - 2 digit track number
# @A  - performer if found, otherwise artist
# @t  - song title
mp3splt -f -T ${TAG_VER} -C ${ID3V2_ENC} -c "$CUE" -o "@N2 - @t" "${NAME}.mp3"
rm "${NAME}.mp3"

# Write RVA2 id3v2.4.0 tag
mp3gain -s i *.mp3
