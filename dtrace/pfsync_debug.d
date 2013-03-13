#!/usr/sbin/dtrace -s

fbt::pfsync_input:entry
{
	printf("%Y m->m_pkthdr.len=%u %u",
			walltimestamp, ((struct mbuf *)arg0)->M_dat.MH.MH_pkthdr.len,
			((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_hl
	);
}

fbt::pfsync_in_eof:entry
{
	/* arg1 - struct mbuf *m, arg2 - int offset */
	printf("%Y m->m_pkthdr.len=%u offset=%u count=%u",
			walltimestamp, ((struct mbuf *)arg1)->M_dat.MH.MH_pkthdr.len, arg2, arg3);
}

/*

fbt::m_pulldown:return
/arg1 == 0/
{
        printf("%s+0x%x returned 0x%x", probefunc, arg0, arg1);
}

*/
