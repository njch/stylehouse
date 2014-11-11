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
    "A $A->{id} >".$A->{i}->pi();
}

sub spawn {
    my $A = shift;
    $H->spawn({uA => $A, r=>[@_]});
}

sub An {
    my $A = shift;
    my $n = shift;
    push @{$A->{n}}, $n unless grep { $_ eq $n } @{$A->{n}};
}

sub Au {
    my $A = shift;
    my $u = $A->fiA(shift);
    my $t = shift;
    #$A->sag("Au changes from ", $A->{u}, $u) if $A->{u};
    $A->{u_t}->{$t} = $u;
    $A->{u} = $u;
}

sub p {
    my $A = shift;
    $A->{i}->{K} || $A->{i}->{name}
}

sub sag {
    my $A = shift;
    say $A->p ." ".shift(@_)." ".join"   > ",map {$_->p} @_;
}

sub fiA {
    my $A = shift;
    my $u = shift;
    $u = $u->{A} if ref $u ne 'A';
    die "no A finding" if ref $u ne 'A';
    $u
}

sub fiu {
    my $A = shift;
    my $sh = shift;
    my $a = $A;
    until (ref $a->{i} eq $sh) {
        die "no finding $sh" unless $a->{u} && $a->{u} ne $a;
        $a = $a->{u};
        ref $a eq "A" || die "atrain malt";
    }
    $a->{i}
}

sub to {
    my $A = shift;
    my $to = shift;
    grep { $_->{K} =~ /^$to$/ } @{$A->{n}}
}

sub path {
    my $A = shift;
    my $up;$up = sub {
        my $a = shift;
        return $a, $up->($a->{u}) if $a->{u} && $a->{u} ne $a;
    };
    my @path = reverse $up->($A);
    #return join "/", map { ref $_ } @path;
}

'stylehouse'