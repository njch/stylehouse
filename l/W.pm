package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $W = shift;
    $W->{name} = "Wormhole for $W->{A}->{u}->{i}->{name}";
    
    $W
}

'stylehouse'