#!/usr/sbin/dtrace -s

#pragma D option flowindent

syscall::sendto:entry
/execname == "p0f-sendsyn"/
{
	self->traceme = 1;
	printf("fd: %d", arg0);
}

fbt::rip_output:return
/self->traceme/
{
	printf("%s+%x returned %d", probefunc, arg0, arg1);
}

fbt:::
/self->traceme/
{}

syscall::sendto:return
/self->traceme/
{
	self->traceme = 0;
	exit(0);
}
