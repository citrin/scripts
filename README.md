Some small and simple scripts used by me for for various tasks. Most of them tested only under FreeBSD.

* dovecot-maildir2mbox.pl - convert Maildir to Dovecto mbox
* dhcpd-static-route.pl - generate classless static route option string for ISC DHCP, [more info](http://ospf-ripe.livejournal.com/5488.html) (in russian)
* flac_cue_to_mp3.sh - convert flac/wv image + CUE to set of mp3 files with ID3 tags from CUE
* gajim_history.pl - show last N (100 by default) messages from [Gajim](http://gajim.org/) history (stored in SQLite DB)
* gmirror-rebuild.sh - run gmirror rebuild for stale components after full server startup
* grabssh - fix ssh-agent forwarding when attaching to an existing [tmux](http://tmux.sourceforge.net/) or screen
* hdd-r-speed.sh - run short read benchmark for all HDD
* jpeg2pdf.sh - pack several jpeg images into single pdf file (wrapper around [gs](http://www.ghostscript.com/))
* lib_check.sh - list dynamic executables that have unresolvable shared library links
* ozi-map-merge.pl - generate Global Mapper script to merge raster maps (georeferenced by OziExplorer)
* procstat-v.pl - parse 'procstat -v' (FreeBSD) output and show in human readable form
* resize.sh - resize photos (before publish)
* send-xmpp - perl script to send IM messages over XMPP protocol (Jabber)
* simplify-gps-track.sh - wrapper around [gpsbabel](http://www.gpsbabel.org/) - reduce track to 400 points (useful to show on web site e. g. maps.google.com)
* split-image.sh - split an image into 4 smaller ones (e. g. to print A3 image on A4 printer)
* vmstat_memory.pl - print 'vmstat -m' and 'vmstat -z' (FreeBSD) sorted by memory usage
