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

sub pi {
    my $W = shift;
    "W $W->{name}";
}

'stylehouse'