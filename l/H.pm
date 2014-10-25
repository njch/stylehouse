package H;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use lib 'l';
use A;
use C;
use G;
use H;
use W;
sub wdump{Ghost::wdump(@_);}

sub new {
    my $H = shift;
    $H = bless {}, $H;
    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $W::H = $H;
    die wdump($A::H);
    
    $H
}

sub spawn0 {
    my $H = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
}

'stylehouse'