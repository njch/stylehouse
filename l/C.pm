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

'stylehouse'