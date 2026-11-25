#!/usr/bin/perl
# One TNC2 packet per input line, hex-encoded; one JSON object per output line: Ham::APRS::FAP's parse of it.
use strict;
use warnings;
use Ham::APRS::FAP qw(parseaprs);
use JSON::PP;
# ASCII only: comment bytes come out as \u00XX (one per byte).
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
while (my $hex = <STDIN>) {
    chomp $hex;
    my $raw = pack('H*', $hex);
    my %h;
    my $ok = parseaprs($raw, \%h);
    delete $h{origpacket};
    delete $h{header};
    delete $h{body};
    $h{ok} = $ok ? 1 : 0;
    $h{raw} = $hex;
    print $json->encode(\%h), "\n";
}
