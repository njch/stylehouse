package R;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
our $f = {};
fstyles();

sub new {
    my $R = shift;
    $R->{name} = shift;
    $R->{G} = $R->{A}->fiu('G');
    $R->{A}->umv("", "R");
    $R->{A}->umk($G::F[0], 'spawn');
    $R->{etcarg} = [@_] if @_;
    $H->{G} ->w("_init_R", {R => $R});

    $R
}

sub from {
    my $R = shift;
    my $s = shift;
    my $a = shift;
    my $u = $R;
    $R->dfrom({u=>$R, s=>$s});
    return $R;
}

sub dfrom {
    my $R = shift;
    my $a = shift;
    my $u = $a->{u};
    my $s = $a->{s};

    my $sk = {map{$_=>1}qw"uuid id G A T"};
    my $axi = ref $u ne "HASH"; # on ACGTR or so

    for my $k (keys %$s) {
        next if $axi && $sk->{$k};
        # Li or Lo? TODO gonerism and schemas dusly
        my $t = $u->{$k};
        my $f = $s->{$k};

        if ($k =~ /^(.+)!(.+)$/) {
            $k = $1;
            my $uu = $R->{A}->spawn($2);
            $uu->from($f);
            $f = $uu;
        }
        elsif ($f && $k =~ /^(B|S)$/) {
            $t ||= {};
            ref $t eq "HASH" || die;
            $R->dfrom({u=>$t, s=>$f});
            $f = $t;
        }

        $u->{$k} = $f;
    }
    return $u;
}

sub pi {
    my $R = shift;
    "R $R->{name}"  
}

sub f {
    my $R = shift;
    my @styles = split "_", shift;
    my $t = shift;
    my $ff = shift;
    @styles = map { $f->{$_} || $ff && $ff->{$_} || die "no style $_" } @styles;
    qq{<span style="@styles">$t</span>};
}

sub fstyles {
    my $R = shift;
    $f->{fs150} = "font-size:150%;";
    $f->{fs120} = "font-size:120%;";
    $f->{fs40} = "font-size:40%;";
    $f->{fs80} = "font-size:80%;";
    $f->{fs60} = "font-size:60%;";
    $f->{white} = "color:white;";
    $f->{blue} = "color:blue;";
    $f->{red} = "color:#fca;";
    $f->{lightblue} = "color:#44f;";
    $f->{black} = "color:black;";
}

sub loadup {
    my $R = shift;
    my ($i, $k, $v) = @_;
    my $s = $R->snapple($k); # chunks {G{GG{etc 3
    $s->{e} = $v;
    $R->suets($i, $s);
}

sub suets {
    my $R = shift;
    my ($i, $s) = @_;
    my @s = @{$s->{s}};
    my $end = pop @s if exists $s->{e};
    my $last;
    while (1) {
          my $ac = shift @s || do {exists $s->{e} || last; $last=1; $end};
        $ac =~ /^(\W)(\w+)$/ || die;
        if (!$last) { # TODO know about insto hash or array...
            $i = $i->{$2} ||= {} if $1 eq "{";
            $i = $i->[$2] ||= {} if $1 eq "[";
        }
        else {
            $i->{$2} = $s->{e} if $1 eq "{";
            $i->[$2] = $s->{e} if $1 eq "[";
            last;
        }
    }
}

sub snapple {
    my $R = shift;
    my $k = shift;
    ($k, my $v) = $k =~ /^(\S+)(?: (.+))?$/;
    my $a = {k => $k, v => $v};
    my @s;
    while ($k =~ m/(\W\w+)/sg) {
          push @s, $1;
    }
    $a->{s} = \@s;
    $a
}

sub wtf {
    my $R = shift;
    my $a = shift;
    # fractionating importantness into spacetime
    if ($a->{way} && $a->{div}) { # spawn
        $a->{now} ||= 0;
        $R->{wtf}->{$a->{way}} = $a;
        return;
    }
    # inf
    my $riv = $R->{wtf} ||= {};
    while (my ($way,$r) = each %$riv) {
        $r->{now}++;
        if ($r->{now} >= $r->{div}) {
            $r->{now} = 0;
            $R->{G}->timer(0.0000001, sub {
                $r->{last_hit} = $H->hitime;
                return $r->{D}->() if $r->{D};
                $R->{G}->w("$way");
            });
        }
    }
}

9;

