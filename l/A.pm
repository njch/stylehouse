package A;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
sub new {
    my $A = shift;
    my $u = shift;
    $A->{u} = $u;
    $u->{A} = $A;
    
    $A
}

sub spawn {
    my $A = shift;
    my $uu = $H->spawn(@_);
    $A->{u}->{A}->An($uu);
    $uu
}

sub An {
    my $A = shift;
    my $n = shift;
    push @{$A->{n}}, $n;
}

sub path {
    my $A = shift;
    my $up;$up = sub {
        my $u = shift;
        return $u, $up->($u->{A}->{u}) if $u->{A} && $u->{A}->{u} && $u ne $u->{A}->{u};
    };
    my @path = reverse $up->($A->{u});
    return join "/", map { ref $_ } @path;
}

'stylehouse'