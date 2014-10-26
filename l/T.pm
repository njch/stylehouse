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
    push @{$T->{L}||=[]}, {
        B => G::du({ O=>$T, 
        name => [@_],
    };
}

sub copi {
    my $T = shift;
}

'stylehouse'