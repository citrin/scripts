#!/usr/bin/perl

# parser for FreeBSD command procstat -v
# see man procstat(1) for details

use 5.012;
use warnings;

# XXX - may be res/pres/shadow no always 4k pages, but also superpages (if used).
use constant PAGE_SIZE => 4096;

# VM object types
my %vm_obj_types = (
	'--' => 'none',
	'dd' => 'dead',
	'df' => 'default',
	'dv' => 'device',
	'ph' => 'physical',
	'sg' => 'scatter/gather',
	'sw' => 'swap',
	'vn' => 'vnode',
);

my $l = <STDIN>;

die unless $l =~ /PID\s+START\s+END\s+PRT\s+RES\s+PRES\s+REF\s+SHD\s+FL\s+TP\s+PATH/;

my $vm_objs;

while ($l = <STDIN>) {
	chomp $l;
	$l =~ s/^\s+//;
	my @l = split /\s+/, $l, 11;
	my $pid = $l[0];
	my $type = $l[9];
	my $size;
	{
		use bignum;
		$size = hex($l[2]) - hex($l[1]);
	}
	push @{ $vm_objs->{$pid}->{$type} },
		{
			size   => $size,
			prot   => $l[3],
			res    => $l[4] * PAGE_SIZE,
			pres   => $l[5] * PAGE_SIZE,
			ref    => $l[6],
			shadow => $l[7] * PAGE_SIZE,
			flags  => $l[8],
			path   => $l[10],
		};
}

foreach my $pid (sort keys %$vm_objs) {

	my $size = 0;
	say "\n=== PID $pid ===\n";

	foreach my $type ( sort keys %{ $vm_objs->{$pid} } ) {

		say 'Objects with type: ' . $vm_obj_types{$type};

		foreach ( sort { $b->{res} <=> $a->{res} } @{ $vm_objs->{$pid}->{$type} } ) {
			printf "%s %s size %7s, RES %7s, PRES %5s, shadow %5s, ref count %3d\n",
				$_->{prot}, $_->{flags}, hum_size($_->{size}), hum_size($_->{res}), hum_size($_->{pres}), hum_size($_->{shadow}), $_->{ref};
				$size += $_->{size};
		}
		say '';
	} # type
	say "Summary size: " . hum_size($size);
}

###############################################################################

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
