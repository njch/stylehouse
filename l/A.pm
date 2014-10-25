package A;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
sub new {
    my $A = shift;
    my $u = shift;
    $A->{u} = $u;
    $u->{A} = $A;
    
    $A
}

sub spawn {
    my $A = shift;
    $H->spawn(@_);
}

'stylehouse'