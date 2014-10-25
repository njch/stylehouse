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
    $W->{name} = "$W->{A}->{u}->{i}->{name}"; # TODO A tract mixinout naming
    $W->{G} = $W->{A}->{u}->{i};
    $W->{n} = 0;
    $W->wormfile_load(shift);
    
    $W
}

'stylehouse'