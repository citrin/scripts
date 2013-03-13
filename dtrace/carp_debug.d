#!/usr/sbin/dtrace -s

fbt::ip_output:entry
	/((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p == 1/
{
	printf("%Y proto=%u ttl=%u\n", walltimestamp,
		((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p,
		((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_ttl);
	stack(4);
}

fbt::dummynet_send:entry
	/((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p == 1/
{
	printf("%Y proto=%u ttl=%u\n", walltimestamp,
		((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_p,
		((struct ip *)(((struct mbuf *)arg0)->m_hdr.mh_data))->ip_ttl);
	stack(4);
}
