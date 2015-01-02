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

sub du {
    my $R = shift;
    my $a = shift || $R->{a};
    $a || die;
    defined $a->{i} || die;
    # how to get around the Objs' data
    my $s = $a->{s} ||= $R->dus();
    my $i = $a->{i};
    my $n = $a->{n};
    $a->{e} = 2 if !defined $a->{e};

    my $c = {};
    $a->{as} ||= [];
    push @{$a->{as}}, $a;
    $a->{ds} = [@{$a->{ds}||[]}, $a];

    return {} if @{$a->{ds}} > 12 || 2 < grep {ref $_->{i} && $_->{i} eq $i} @{$a->{as}};

    my $ref = ref $i || 'SCALAR';
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    my $mustb = { map { $_ => 1 } split ',', $is->{mustb} } if $is->{mustb};

    for my $j ($is->{it}->($i)) {
        my $k = delete $j->{k};
        my $K = delete $j->{K};
        my $v = delete $j->{v};

        $j = {%$is, %$j};
        my $an = {%$a, i => $v};

        my $ohms = defined $j->{oh} ? $j->{oh}
            : defined $is->{oh} ? $is->{oh}
          : 1;

        $an->{e} -= $ohms;

        my $rk = join "\t", $k, $an->{e};

        $c->{$rk} = $v;

        $a->{tr}->{rows}++;
        last if $a->{tr}->{rowlimit} && $a->{tr}->{rows} >= $a->{tr}->{rowlimit};

        if ($an->{e} >= 1 && ref $an->{i}) {
            my $cu = $R->du($an);
            while (my ($ku, $vu) = each %$cu) {
                my $nk = $k.$ku;
                next if grep { $_->($_, $an, $cu) } @{$s->{notZ}||[]};
                $c->{$nk} = $vu;
            }
        }
        elsif ($an->{e} > 0 && $an->{e} < 1 && $mustb && !$mustb->{$K}) {
            delete $c->{$rk};
        }
    }

    if ($R->{a} == $a) {
        $R->{a}->{d} = $c;
    }

    # this is about a 4 - material for links
    $c
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

sub dus {
    my $R = shift;
    my $h = {
      ARRAY => {
        it => sub {
          my $h = shift;
          my $i = 0;
          map { { k => "[".$i++, v => $_ } } @$h
        },
        oh => 0,
      },
      HASH => {
        it => sub {
          my $h = shift;
          map { { K=>$_, k=>"{".$_, v=>$h->{$_} } } sort keys %$h
        },
      },
    };
    my $an = sub {
        my $k = shift;
        my $i = $h->{$k} ||= {it => $h->{HASH}->{it}};
        %$i = (%$i, @_);
    };
    # make so 1.2 means if e>=0.5 traverse with e-=0.2
    # drops 1 every traversal too...
    # cept for sometimes when there's a deeper number in e
    # saying from above via style schema how to curle around
    # the 1-9, wherever
    # then anomalies are mapped with names & meaning in stylegrab 78

    $an->(qw'A oh 0.2');
    $an->(qw'C oh 0.2');
    $an->(qw'G oh 0.2');
    $an->(qw'T oh 0.2');
    $an->(qw'R oh 0.2');

    $an->(qw'W oh 0.2 mustb','id,hash,file,G');
    $h
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

sub popJtrav {
    my $R = shift;
    $R->{J}->{trav} =~ s/\W\w+$//;
}

sub intJtrav {
    my $R = shift;
    my $k = shift;
    if ($k eq "0") {
          if ($R->{ksuc} && $k eq "0") {
            return $R->{ksuc} = ""
        }
        return $R->popJtrav
    }

    my $j = $R->{a}->{ro}->{$k};
    if (!$j) {
          return $R->{ksuc} .= $k
    }
    $R->{ksuc} = "";

    my ($hop) = $j->{ac} =~ /^(\W\w+)/;
    $R->{J}->{trav} .= $hop;
}

sub uni {
    my $R = shift;
    my ($i, $t) = @_;
    my @tr = split /(?=\{|\[)/, $t;

    for (@tr) {
        /^(.)(.+)$/;
        last if $1 eq " ";
        $i = $i->{$2} if $1 eq "{";
        $i = $i->[$2] if $1 eq "[" && (ref $i eq 'ARRAY' || die "NOT!");
    }
    if ($t =~ m/^.+? (.+)$/) {
        say "Had some more: $1";
    }
    $i
}

sub durows {
    my $R = shift;
    my $d = $R->{a}->{d};
    my @r = %$d;
    $R->{a}->{r} = [map {[ $_, $d->{$_} ]} sort keys %$d];
}

sub dustill {
    my $R = shift;
    my $r = $R->{a}->{r};
    $_->[2] = G::slim(96,80,G::gp($_->[1])) for @$r;
    @$r;
}

sub S {
    my $R = shift;
    $R->{a} = my $a = shift || {};
    # 2
    $a->{e} ||= $R->{S}->{e} || die;
    $a->{i} ||= $R->uni;
    $a->{tr}->{rowlimit} = $R->{S}->{rowlimit} || 9*3;
    # TODO ^ tunes the rowiness
    # which is the first variable to other distortions
    # so basically chomps produced Style cloud after yay many Whats
    # the v is Vaults, decaying energy
    # there'd be a gravity somewhere
    # 3
    $R->du;
    die "nod" unless $a->{d}; 
    # 4
    $R->durows;
    # the buzziness comes off
    return;
    # 5
    $R->dustill;
    # 6 ?
    # fork sends travel back later with more depth to $R ->w("S", {%$ar}),7
    # 7
    # reflect style injection round corner
    # throw style into ux recipe
    my $i = 1;
    my @rows = map {
        my ($ac, $li, $pi) = @$_;
        $ac =~ s/\s+/ /g;
        join "  ", map { $R->f(@$_) }
          [ black => $ac ],
          [ blue_fs80 => $i++ ],
          [ white_fs120 => $pi ],
    } @{$R->{a}->{r}};

    my $title = "= ".$R->f(white_fs150 => G::gp($a->{i}));
    my $Jpi = "@!@".$R->f(white => G::gp($R->{J}->{from}))
        ."  ".$R->f(black => $R->{J}->{trav});

    join "\n", $Jpi, $title, @rows;
}

sub gp {
    my $R = shift;
    my $u = shift;
    my $v = shift; 
    my $piok = ref $u && ref $u ne 'HASH' && ref $u ne 'CODE'
        && ref $u ne 'ARRAY' && $u->can('pi');

    return $u->pi if $piok;

    ghostlyprinty('NOHTML',@_);
}

sub dust {
    my $R = shift;
    my $a = {i=>shift, e=>3};

    my $d = $R->du($a);

    my @or = sort keys %$d;
    @or = map {[ $_, $d->{$_} ]} @or;
    $_->[2] = G::slim(96,80,G::gp($_->[1])) for @or;
    my @rows = map { join "  ", $_->[0], $_->[2] } @or;

    return join "\n", @rows;
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

9