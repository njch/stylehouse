#!/usr/bin/perl
use strict;
use warnings;
# the fact that THIS is the only thing recommended to be in here is beautiful
# and it's not even a tomb: it's really a Texty producer
# and through there somewhere is stylehouse
use Scriptalicious;
# last THAT joke I promise
# I didn't even notice there was no depth
# music's about feeling good anyway because

# sub get_goya { # tried it just named goya
# only Hostinfo can truly get goya because it's the one place that's finally one thing

# it's always ripples we're feeling through something

my $space = [
    map { { top => $_ } } 1..30
];
my $junk;
my $min = {};
my $max = {};
for my $span (@$space) {
    for my $ang (qw{ top }) {
        my $value = $span->{$ang};

        push @{ $junk->{$ang}->{$value} ||= [] }, $span;

        if (!$max->{$ang} ||
            $max->{$ang} < $value) {
            $max->{$ang} = $value;
        }
        if (!$min->{$ang} ||
            $min->{$ang} > $value) {
            $min->{$ang} = $value;
        }
    }
}

my $amp = 1.2;
my $q = 0.5;

my $synthspace = sub {
    my $angle = shift;
    my $span = shift;
    my $min = $min->{$angle};
    my $max = $max->{$angle};
    my $half = $max / 2;

    my $gone = $span->{$angle} - $min;
    my $way = $gone / $max; # way is the tiny thing
    my $spec = 0.5 - $way;
    $spec *= -1 if $spec < 0;
    my $qfactor = $spec + $q;
    my $mag = $spec ** $qfactor;

    my $move = $mag * $amp;

#        $qfactor = -$q if $way < $half;
#        my $x = $qfactor * $way * $q;
#        $way += $x;
    
    my $blah = int($mag * 50);
    my $bar = $blah." ".join "", "D" x $blah;
    say "\t$bar";

    $span->{"old_$angle"} = $span->{$angle};
    $span->{$angle} += $way + $min;
   # my $c = $changes->{$span->id} ||= {};
   # $c->{$angle} = $way; # but you had to gethere
};

for my $angle (qw{ top }) {
    #$changes->{$angle} ||= [];
    for my $span (@$space) {
        $synthspace->($angle => $span);
    }
}



