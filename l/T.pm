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
    $T->commit(@_);

    $T
}

sub commit {
    my $T = shift;
    push @{$T->{B}||=[]}, $T->copi;
}

sub copi {
    my $T = shift;
    my $i = $_[0] || $T->{i};
    my $c = {};
    for my $k (keys %$i) {
        $c->{$k} = $i->{$k};
    }
    $c
}

'stylehouse'