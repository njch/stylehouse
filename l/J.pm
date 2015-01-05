package J;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $J = shift;
    $J->{R} = $J->{A}->{u}->{i};
    if (ref $J->{R} eq "G") {
        $J->{R} = $J->{R}->{G}->{R};
        $J->{G} = $J->{R}->{G};
    }
    #$J->{R}->dfrom($J, {B=>shift});

    $J
}

sub s {
    my $J = shift;
    $J->{R} = $J->{A}->{u}->{i};
    if (ref $J->{R} eq "G" && 0) {
        $J->{R} = $J->{R}->{G}->{R};
        $J->{G} = $J->{R}->{G};
    }
    #$J->{R}->dfrom($J, {B=>shift});
}

sub pi {
    my $J = shift;
    "J(".$J->{R}->pi;
}

9
