package C;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Way';

sub new {
    my $C = shift;
    $C->{G} = $C->{A}->{u}->{i};

    $C
}

sub pi {
    my $C = shift;
    my $some = "C ".$C->pint();
    unless (length($some) > 5) {
        $some .= " ".Ghost::ki($C);
    }
    $some
}

'stylehouse'