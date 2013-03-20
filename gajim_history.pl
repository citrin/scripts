#!/usr/bin/perl

# portmaster databases/p5-DBD-SQLite

use 5.012;
use warnings;
use open ':locale';

use POSIX qw(strftime);

use DBI;

my $gajim_db = ($ENV{HOME} || '.') . '/.local/share/gajim/logs.db';
my $number = shift || 100;

my $dbh = DBI->connect("dbi:SQLite:dbname=$gajim_db", '', '');
$dbh->{sqlite_unicode} = 1;

# https://trac.gajim.org/wiki/LogsDatabase
my $sth = $dbh->prepare('SELECT time, kind, jid, message
		FROM logs,jids
		WHERE jids.jid_id=logs.jid_id AND (logs.kind >= 3 AND logs.kind <= 6) ORDER BY time DESC LIMIT ?');
$sth->execute($number);

my @lines;
while (my $r = $sth->fetchrow_hashref) {
	my $time = strftime('%F %H:%M', localtime $r->{time});

	my $jid = $r->{jid};

	if ($r->{kind} == 3 || $r->{kind} == 4) {
		# 'single_msg_recv' (value 3), 'chat_msg_recv' (value 4)
		$jid .= ' >> me';
	} elsif ($r->{kind} == 5 || $r->{kind} == 6) {
		# 'single_msg_sent' (value 5), 'chat_msg_sent' (value 6)
		$jid = 'me >> '.$jid;
	}

	$jid .= ':';
	push @lines, join ' ', ($time, $jid, $r->{message});
}
$dbh->disconnect;

say while $_ = pop @lines;
