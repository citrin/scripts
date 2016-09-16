#!/usr/bin/perl

use 5.012;
use warnings;
use autodie;

use File::Basename;
use Getopt::Long;
use Pod::Usage;

my $formatter = 'formail'; # installed with procmail

pod2usage(2) if scalar @ARGV != 2;

my $in_mdir  = $ARGV[0];
my $out_mbox = $ARGV[1];

if ( -f $out_mbox ) {
	die "$out_mbox already exists\n";
}

my $keywords = load_keywords("$in_mdir/dovecot-keywords");

my @in_files;

for my $subdir ("$in_mdir/cur", "$in_mdir/new") {
	opendir(my $dh, $subdir);
	while (readdir $dh) {
		next if /^\./ || ! -f "$subdir/$_";
		push @in_files, "$subdir/$_";
	}
	closedir $dh;
}

# sort by timestamp in filename
@in_files = sort {
	my $aa = basename($a);
	$aa =~ s/^(\d+)\..*$/$1/;
	my $bb = basename($b);
	$bb =~ s/^(\d+)\..*$/$1/;
	$aa <=> $bb
} @in_files;

foreach my $in_file (@in_files) {
	# extract flags from filename
	warn "bad filename format: $in_file"
		unless $in_file =~ /:2,([A-Z]*)([a-z]*)$/;

	my %flags = map { $_ => 1 } split //, $1;
	my @kw = split //, $2;

	my $kw_header = 'X-Keywords:';
	foreach (@kw) {
		$kw_header .= ' '. %$keywords{$_};
	}

	# XXX non-\Recent flag is always added, I'm lazy
	my $status_header = 'Status: ' .
		( $flags{S} ? 'RO' : 'O' );

	my $x_status_header = 'X-Status: ';
	# Maildir flags: http://cr.yp.to/proto/maildir.html
	# dovecot flags: http://wiki.dovecot.org/MailboxFormat/mbox
	$x_status_header .= 'A' if $flags{R}; # \Answered - replied
	$x_status_header .= 'F' if $flags{F}; # \Flagged - flagged
	$x_status_header .= 'T' if $flags{D}; # \Draft - draft
	$x_status_header .= 'D' if $flags{T}; # \Deleted - trashed

	# There is "P" (passed) flag in maildir, but I have no messages to test

	$in_file =~ s/'/'"'"'/g;  # escape ' (single quote)
	my $cmd = "$formatter -A '$status_header' -A '$x_status_header' -A '$kw_header' < $in_file >> $out_mbox";
	system($cmd) == 0 or die "system $cmd filed: $?";
}

##############################################################################

sub load_keywords {
	my $f = shift;
	my %k; #  letter -> label, e. g. a -> NonJunk
	# in dovecot-keywords file labels numbered by 0, 1, 2 ...
	# in maildir filename flags letters a, b, c, ... z are used
	open my $fh, '<', $f;
	while (<$fh>) {
		chomp;
		die "bad line: $_" unless /^(\d+)\s+(\S+)$/;
		# 0 -> a, 1 -> b, 2 -> c, e. t. c.
		my $letter = chr(ord('a') + $1);
		$k{$letter} = $2;
	}
	close $fh;
	return \%k;
}

__END__

=head1 NAME

dovecot-maildir2mbox.pl - convert maildir to mbox

=head1 SYNOPSIS

dovecot-maildir2mbox.pl maildir/.Sent mailbox/Sent

=head1 DESCRIPTION

dovecot-maildir2mbox.pl is a script to convert maildir with dovecot extensions
to mbox (with dovecot's metadata).

To convert maildir run the script with two arguments:

=over 2

=item *
  path to directory with maildir (with cur and new subdirs inside)

=item *
  path to mailbox file to be created

=back

Script converts one folder at time, to convert whole mailbox run it for each folder.

See L<http://wiki2.dovecot.org/MailboxFormat/Maildir> and
L<http://wiki.dovecot.org/MailboxFormat/mbox> for formats description.

UIDVALIDITY and UIDs are not converted by this script.

Recent flag is not preserved (all messages marked as non-recent).
