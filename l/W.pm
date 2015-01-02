package W;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
# nothing!

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
        join("",("  ")x($G::T->{depth}||1))."l-$W->{n} ";
    my $L = {
        uuid => $H->mkuid,
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

sub ob {
    my $W = shift;
    $W->{G}->ob(@_);
}

sub CS {
    my $W = shift;
    [@{$W->{script}}]
}

sub wormfile_load {
    my $W = shift;
    $W->{file} = shift;
    if ($W->{file} && -e $W->{file}) {
        my $s = $W->{script} = Load($H->slurp($W->{file}));
        die " script (loaded from $W->{file}) ne ARRAYref: ".($s||"~undef~")
            unless ref $s && $s eq "ARRAY";
        say "W $W->{file} loaded";
    }
    else {
        $W->{script} = [];
    }
}

sub wormfile_check {
    my $W = shift;
    my $file = $W->{file};
    unless (-e $file) {
        say "no $file";
        my ($wom) = $file =~ qr{(wormholes/.+)/};
        unless (-e $wom) {
            mkdir $wom;
        }
        `touch $file`;
    }
}

sub findL {
    my $W = shift;
    my $id = shift || return;
    my ($L) = grep { $_->{uuid} eq $id } @{$W->{script}||[]};
    $L;
}

9