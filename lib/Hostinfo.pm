package Hostinfo;

use strict;
use warnings;

my $hostinfo = {};

sub set {
    my ($self, $i, $d) = @_;
    $hostinfo->{$i} = $d if $d;
    return $hostinfo->{$i};
}


sub new { bless {}, shift }

1;
