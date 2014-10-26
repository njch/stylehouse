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
    $T->name(shift);
    $T->commit(shift);

    $T
}

sub name {
    my $T = shift;
    $T->{name} = shift || Ghost::gpty($T->{A}->{u}->{i});
}

sub commit {
    my $T = shift;
    my $mes = shift;
    $T->{L} ||= [];
    $mes ||= "init" if !@{$T->{L}};
    $mes ||= "?";
    my $L = {
        B => G::du({ O=>$T, i=>$T->{A}->{u}->{i} }),
        mes => $mes,
    };
    push @{$T->{L}||=[]}, $L;
    $T->{HEAD} = $T->{L}->[-1];
}

'stylehouse'