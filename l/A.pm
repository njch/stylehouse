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
    my $n = $A->fiA(shift);
    my $l = $A->mklt(n => @_);
    $A->accum($A, $l, $n);
}

sub Au {
    my $A = shift;
    my $u = $A->fiA(shift);
    my $l = $A->mklt(u => @_);
    return $A->{u} = $u if $l eq "u";
    $A->accum($A, $l, $u);
}

sub rAn {
    my $A = shift;
    my $n = $A->fiA(shift);
    my $l = $A->mklt(n => @_);
    $A->deaccum($A, $l, $n);
}

sub rAu {
    my $A = shift;
    my $u = $A->fiA(shift);
    my $l = $A->mklt(u => @_);
    return $A->{u} = $u if $l eq "u";
    $A->deaccum($A, $l, $u);
}

sub mklt {
    my $A = shift;
    return join "_", grep /./, @_;
}

sub umv {
    my $A = shift;
    # say if we don't want to clutter the G this spawned from
    # as a tidy up
    # and things that don't get tidied up
    # must want more attention
    my ($f, $t) = @_;
    my $Au = $A->{u};
    $Au->rAn($A, $f);
    $Au->An($A, $t);
    $A->rAu($Au, $f);
    $A->Au($Au, $t);
}

sub umk {
    my $A = shift;
    my ($u, $t) = @_;
    my $Au = $A->fiA($u);
    $Au->An($A, $t);
    $A->Au($Au, $t);
}

sub accum {
    my $A = shift;
    my ($s, $ac, $t) = @_;

    my $a = $s->{$ac} ||= [];
    die "ac looks $ac, got  $a " unless ref $a eq "ARRAY";
    return if grep { $_ eq $t } @$a;
    push @$a, $t;
}

sub deaccum {
    my $A = shift;
    my ($s, $ac, $t) = @_;
    my $a = $s->{$ac} ||= [];
    my $i = 0;
    for (@$a) {
        return splice(@$a, $i, 1) if $_ eq $t;
        $i++;
    }
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

9
