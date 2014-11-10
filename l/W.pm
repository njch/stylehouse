package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Wormhole';

sub new {
    my $W = shift;
    $W->{G} = $W->{A}->{u}->{i};
    $W->{name} = "$W->{G}->{name}";
    $W->{n} = 0;
    $W->wormfile_load(shift);

    $W
}

sub continues {
    my $W = shift;
    my $G = shift; # %

    my ($namg) = $W->{G}->{name} =~ /\(\S+[^\)]*\)$/;
    $namg = "$W->{G}->{name} ".
        join("",("  ")x($Ghost::T->{depth}||1))."l-$W->{n} ";
    my $L = {
        uuid => (ref $H eq "H" ? $H->mkuid : $H->make_uuid),
        name => $namg,
        n => $W->{n}++,

        t => $G::T->{t},

        i => $G::T->{i},
        o => $G::T->{o},
        T => $G::T, # LIES?
        G => $G,
        W => $W,

        depth => $G::T->{depth},
    };

    if ($G->deeby) {
        $H->Say("Enters the $namg\t\ti:".$L->{i}->pi);
    }

    push @{$W->{script}}, $L;
    $G->ob("continues...", $L);

    return $L;
}

sub uhigh {
    my $W = shift;
    my $n = $W->{n};
    return "!!" if ref $W->{script} ne "ARRAY";
    my $u = scalar(@{$W->{script}});
    ($u ne $n ? $n : '')."x$u"; # acquire north, get high
}

sub pi {
    my $W = shift;
    "W $W->{name} ".$W->uhigh;
}

'stylehouse'