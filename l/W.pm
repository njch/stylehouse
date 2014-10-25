package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
sub new {
    my $W = shift;
    $W->{name} = $W->{A}->{u}->{name};
    
    $W
}

'stylehouse'