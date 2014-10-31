package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Wormhole';

sub new {
    my $W = shift;
    $W->{G} = $W->{A}->{u}->{i};
    $W->{name} = "$W->{G}->{name}";
    $W->{n} = 0;
    $W->wormfile_load(shift);

    $W
}

sub uhigh {
    my $W = shift;
    my $n = $W->{n};
    my $u = scalar(@{$W->{script}});
    ($u ne $n ? $n : '')."x$u"; # acquire north, get high
}

sub pi {
    my $W = shift;
    "W $W->{name} ".$W->uhigh;
}

'stylehouse'