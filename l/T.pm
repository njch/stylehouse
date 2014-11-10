package T;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $T = shift;
    $T->{i} = $T->{A}->{u}->{i}; # MAINT
    $T->{i}->{T} = $T;
    $T->{name} = shift;
    $T->commit(shift);

    $T
}

sub pi {
    my $T = shift;
    "T $T->{name} x".scalar(@{$T->{L}})." ".$T->{i}->pi(); 
}

sub commit {
    my $T = shift;
    my $mes = shift;
    $T->{L} ||= [];
    $mes ||= "init" if !@{$T->{L}};
    $mes ||= "?";
    my $L = {
        B => $T->{A}->fiu('G')->du({ O=>$T, i=>$T->{i} }),
        mes => $mes,
    };
    push @{$T->{L}||=[]}, $L;
    $T->{HEAD} = $T->{L}->[-1];
}

'stylehouse'