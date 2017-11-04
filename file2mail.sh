#!/bin/sh

set -e

FROM="sender@example.org"
TO="recipient@example.org"

PATH=/bin:/usr/bin:/usr/sbin

FILE=$1

if [ ! -r "$FILE" ]; then
	echo "Usage: $0 file_to_send"
	exit 64
fi

message=`mktemp -t file2kindle`
trap "rm -f $message" INT EXIT TERM

ascii_file_name=$(basename $FILE | iconv -s -f UTF-8 -t KOI7-SWITCHED )
file_mime_type=`file --brief --mime-type "$FILE"`
rfc822_date=$(date -R)
message_id="$(date +%s).$$@$(hostname)"

boundary="x________x"

cat << EOM > $message
To: ${TO}
From: ${FROM}
Subject: File for a kindle
Message-ID: <${message_id}>
Date: ${rfc822_date}
User-Agent: /bin/sh
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="${boundary}"

This is a multi-part message in MIME format.
--${boundary}
Content-Type: text/plain; charset=US-ASCII

Pelase see attached file.
--${boundary}
Content-Type: $file_mime_type
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="${ascii_file_name}"

EOM

openssl base64 < $FILE >> $message

echo "--${boundary}--" >> $message

sendmail -i -t -f $FROM < $message

