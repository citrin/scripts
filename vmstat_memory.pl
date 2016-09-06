#!/usr/bin/perl

use 5.012;
use warnings;

use Getopt::Std qw/getopts/;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

use JSON::XS qw/decode_json/;

my %opts;

getopts('mz', \%opts);

# need -m or -z or both
if (!$opts{m} && !$opts{z}) {
	print STDERR "Usage:\n";
	HELP_MESSAGE(\*STDERR);
	exit 1;
}

my $command = '/usr/bin/vmstat --libxo=json';

$command .= ' -z' if $opts{z};
$command .= ' -m' if $opts{m};

my $s = decode_json(`$command`);

if ($opts{z}) {
	my @zones = sort {
		$b->{size} * ($b->{used} + $b->{free}) <=>
			$a->{size} * ($a->{used} + $a->{free})
	} @{ $s->{'memory-zone-statistics'}->{zone} };

	my $total = 0;

	printf "Item                    Used    Free   Limit\n";

	foreach my $z (@zones) {
		my $size = $z->{size};
		printf "%-20s %7s %7s %7s\n",
			$z->{name}, hum_size($z->{used} * $size), hum_size($z->{free} * $size),
				$z->{limit} ? hum_size($z->{limit} * $size) : '-';
		$total += ($z->{used} + $z->{free}) * $size;
	}

	printf "\nUMA TOTAL: %s in %d zones\n", hum_size($total), scalar @zones;
}

print "\n" if $opts{z} && $opts{m};

if ($opts{m}) {
	my @types = sort {
		$b->{'memory-use'} <=> $a->{'memory-use'}
	} @{ $s->{'malloc-statistics'}->{memory} };

	my $total = 0;

	printf "TYPE           MemUse\n";

	foreach my $t (@types) {
		printf "%-13s %7s\n",
			$t->{type}, hum_size($t->{'memory-use'} * 1024);
		$total += $t->{'memory-use'} * 1024;
	}

	printf "\nMALLOC TOTAL: %s\n", hum_size($total);
}

##############################################################################

sub HELP_MESSAGE {
	my $fh = shift;
	print $fh "$0 [-mz]\n";
	print $fh "\t-m  kernel dynamic memory allocated using malloc(9)\n";
	print $fh "\t-z  memory used by the kernel zone allocator, uma(9)\n";
}

sub hum_size {
	my $num = shift;

	if ($num > 8 * 2**30) {
		return round($num / 2**30) . ' Gb';
	} elsif ( $num > 8 * 2**20) {
		return round($num / 2**20) . ' Mb';
	} elsif ( $num > 8 * 2**10) {
		return round($num / 2**10) . ' Kb';
	} else {
		return $num . ' b';
	}
}

sub round {
	return int($_[0] + 0.5);
}
