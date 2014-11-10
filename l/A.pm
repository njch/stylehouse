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

    # return if dark
    # links() injects, via accum, itself

    $A
}

sub pi {
    my $A = shift;
    "A $A->{id} ".$A->{i}->pi();
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
    my $u = $A->fiA(shift);
    my $t = shift;
    die "KNow ".G::ki($A->{ut})."  ". G::sw($A->{u}->{i}) if $A->{u};
    $A->{ut}->{$t} = $u;
    $A->{u} = $u;
}

sub fiA {
    my $A = shift;
    my $u = shift;
    $u = $u->{A} if ref $u ne 'A';
    die "no A finding" if ref $u ne 'A';
    $u
}

sub to {
    my $A = shift;
    my $to = shift;
    grep { $_->{K} =~ /^$to$/ } @{$A->{n}}
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