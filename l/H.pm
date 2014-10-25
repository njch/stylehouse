package H;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use Ghost;
sub wdump{Ghost::wdump(@_);}

sub new {
    my $H = shift;
    die wdump($H); 
    
    $H
}

sub spawn0 {
    my $H = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
}

'stylehouse'