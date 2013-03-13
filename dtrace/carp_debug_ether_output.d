#!/usr/sbin/dtrace -s

/* 112 - CARP protocol number */

fbt::ip_output:entry
        /((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p == 112/
{
        printf("%Y proto=%u ttl=%u id=%u flags=%d imo=0x%p\n", walltimestamp,
                ((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p,
                ((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_ttl,
		((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_id,
		arg3,
		arg4
	);
        stack(3);
}

fbt::ether_output:entry
	/((struct ip *)(((struct mbuf *)arg1)->m_hdr.mh_data))->ip_p == 112/
{
	printf("%Y proto=%u ttl=%u id=%u\n", walltimestamp,
		((struct ip *)(((struct mbuf *)arg1)->m_hdr.mh_data))->ip_p,
		((struct ip *)(((struct mbuf *)arg1)->m_hdr.mh_data))->ip_ttl,
		((struct ip *)(((struct mbuf *)arg1)->m_hdr.mh_data))->ip_id);
	stack(4);
}
