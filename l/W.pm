package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $W = shift;
    $W->{name} = "$W->{A}->{u}->{i}->{name}"; # TODO A tract mixinout naming
    
    $W
}

'stylehouse'