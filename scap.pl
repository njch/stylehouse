#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use v5.10;

my @one = ("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $patterns = {
    string => sub {
        say(my $s = shift);
        my @e = (
["filename", qr{/}],
["relative filename", qr{^\.\.}],
["relative filename", qr{^(?!/)}],
["absolute filename", qr{^/}],
["reachable filename", sub { -e shift }],
["file", sub { -f shift }],
["reachable dir", sub { -d shift }],
["readable", sub { -r shift }],
        );
        for my $t (@e) {
            if (ref $t->[1] eq "Regexp") {
                next unless $s =~ $t->[1]
            }
            elsif (ref $t->[1] eq "CODE") {
                next unless $t->[1]->($s);
            }
            else {
                say "NO!";
            }
            met("string/$t->[0]", $s);
        }
    },
    etc => sub {
        my $it = shift;
        my @e = (
[ "file size",
    qq { "string/reachable filename"
         && "string/file" },
    sub {
        my $it = shift;
        met("file size", $it, (stat($it))[7]);
    },
],

        );
        for my $e (@e) {
            my ($t, $logic, $e) = @$e;
            if (mete_logic($it, $logic) && !mete($it, $t)) {
                $e->($it);
            }
        }
    },
};
our $meta = [];
our $at_total_entropy = 0;

sub met {
    my ($from, $it, $eh) = @_;
    $at_total_entropy = 0;
    push @$meta, { i => $it, f => $from, e => $eh};
}
sub meta {
    my $w = shift;
    grep { $_->{i} eq $w } @$meta;
}
sub mete {
    my $it = shift;
    my ($f) = shift;
    my @m = grep { $_->{f} eq $f } meta($it);
    return @m;
}
sub mete_logic {
    my $it = shift;
    my $l = shift;
    $l =~ s{"(.+?)"}{mete(\$it, "$1")}g;
    say $l;
    if (eval $l) {
        return 11;
    }
    else {
        say "+False!: ".$@
    }
}


use Data::Walk;
sub analyse {
    my $it = shift || $_;
    if (ref $it eq "ARRAY") {
        walk \&analyse, @$it
    }
    else {
        if (meta($it)) {
            $patterns->{etc}->($it);
        }
        elsif (ref \$it eq "SCALAR") {
            $patterns->{string}->($it);
        }
    }
}

until ($at_total_entropy) {
    $at_total_entropy = 1;
    analyse(@one);
}

my $mbyit = {};
for my $e (@$meta) {
    push @{$mbyit->{$e->{i}} ||= []}, [$e->{f}, $e->{e}];
}
say Dump($mbyit);

