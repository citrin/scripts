[Dtrace](http://www.freebsd.org/doc/handbook/dtrace.html) scripts used by me. Some of them is for one-time tasks and useful only as sample for writing other scripts.

* carp_debug - was used to troubleshoot problem with wrong TTL in CAPR packets. Conclusion - dummynet(4) is not compatible with local generated multycast (including carp traffic)
* pfsync_debug.d - was used to debug problem fixed in [r246822](http://svnweb.freebsd.org/changeset/base/246822)
