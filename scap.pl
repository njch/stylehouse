#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use v5.10;

my @one = ("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

my @s = (
["filename", qr{/}],
["relative filename", qr{^\.\.}],
["relative filename", qr{^(?!/)}],
["absolute filename", qr{^/}],
["reachable filename", sub { -e shift }],
["file", sub { -f shift }],
["reachable dir", sub { -d shift }],
["readable", sub { -r shift }],
);


for my $s (@one) {
    say $s;
    for my $t (@s) {
        if (ref $t->[1] eq "Regexp") {
            next unless $s =~ $t->[1]
        }
        elsif (ref $t->[1] eq "CODE") {
            next unless $t->[1]->($s);
        }
        else {
            say "NO!";
        }
        say $t->[0];
    }
}
