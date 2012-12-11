#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw/ceil/;

# sample dhcpd.conf
#
# option classless-route-rfc code 121 = string;
# option classless-route-win code 249 = string;
#
# subnet 192.168.1.0 netmask 255.255.255.0 {
#   range 192.168.1.10 192.168.1.252;
#   option routers 192.168.1.1;
#   option classless-route-win 1d:52:b3:c2:40:c0:a8:01:01:10:c0:a8:c0:a8:01:01;
#   option classless-route-rfc 1d:52:b3:c2:40:c0:a8:01:01:10:c0:a8:c0:a8:01:01;
# }

# Usage:
#   make_classless_option({ "subnet/mask" => "router", "subnet/mask" => "router", ... });

my $routes = {
	'0.0.0.0/0'     => '10.10.124.10', # default route
	'10.12.0.0/16'  => '10.10.124.1',
	'10.10.31.0/24' => '10.10.124.1',
	'10.10.11.0/24' => '10.10.124.1',
	'192.0.2.0/24'  => '10.10.124.1',
};

my $option_value = make_classless_option($routes);

foreach (sort keys %$routes) {
	printf "# %18s => %s\n", $_, $routes->{$_};
}
print "option classless-route-rfc $option_value;\n";
print "option classless-route-win $option_value;\n";

# see RFC 3442
sub make_classless_option {
	my $routes = shift;

	my @bytes = ();

	foreach my $destination (keys %{$routes}) {
		my ($net, $mask) = split '/', $destination;
		die "Bad netmask in $destination" unless $mask =~ /^\d\d?$/ && $mask >= 0 && $mask <= 32;
		push @bytes, $mask;

		my $significant_octets = ceil($mask / 8);
		my @octets = split /\./, $net;
		push @bytes, @octets[0 .. $significant_octets - 1];

		my @gw = split /\./, $routes->{$destination};
		die "Bad gateway " . $routes->{$destination} unless scalar @gw == 4;
		push @bytes, @gw;
	}

	return join(':', map { octet_to_hex($_) } @bytes);
}

sub octet_to_hex {
	my $octet = shift;
	die "Bad octet $octet" unless $octet =~ /^\d{1,3}$/ && $octet >= 0 && $octet <= 255;
	return sprintf('%02x', $octet);
}
