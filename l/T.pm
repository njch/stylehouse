package T;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $T = shift;
    $T->{i} = $T->{A}->{u}->{i};
    die sw($T->{i});
    
    $T
}

'stylehouse'