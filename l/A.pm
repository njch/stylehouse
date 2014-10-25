package A;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $A = shift;
    my $i = shift;
    $A->{i} = $i;
    $i->{A} = $A;
    
    $A
}

sub spawn {
    my $A = shift;
    $H->spawn({uA => $A, r=>[@_]});
}

sub An {
    my $A = shift;
    my $n = shift;
    push @{$A->{n}}, $n;
}

sub Au {
    my $A = shift;
    my $u = shift;
    die if $A->{u};
    $A->{u} = $u;
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