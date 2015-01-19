package R;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
our $f = {};
fstyles();
use POSIX 'ceil';

sub new {
    my $R = shift;
    $R->{name} = shift;
    $R->{G} = $R->{A}->fiu('G');
    $R->{A}->umv("", "R");
    $R->{A}->umk($G::F[0], 'spawn');
    $R->{etcarg} = [@_] if @_;
    $H->{G} ->w("_init_R", {R => $R}); # TODO sets K somewhere

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
    $s = {s=>[$R->{G}->chuntr($s)]} if !ref $s;
    my @s = @{$s->{s}};
    my $end = pop @s if exists $s->{e};
    my $last;
    while (1) {
          my $ac = shift @s || do {exists $s->{e} || last; $last=1; $end};
        $ac =~ /^(\W)(.+)$/ || die "$ac !".G::wdump($s);
        if (!$last) { # TODO know about insto hash or array...
             $i = $1 eq "{" ?
             do { $i = $i->{$2} ||= {} }
             :
             $1 eq "[" ?
             do { $i->[$2] ||= {} }
             :
             die "je seuits $1?";
        }
        else {
            if (exists $s->{e}) {
                $i->{$2} = $s->{e} if $1 eq "{";
                $i->[$2] = $s->{e} if $1 eq "[";
            }
            last;
        }
    }
    $i
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

sub a {
    my $R = shift;
    my $n = shift;
    my $s = shift;

    my $lot = $R->{A}->{"n_$n"} || die "no A\ $n";
    die "empty n_$n" unless @$lot;
    $lot = [@$lot];
    die "make s" if $s; # TODO continue along a path
    @$lot = map{$_->{i}}@$lot;
    wantarray ? @$lot : shift @$lot;
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

sub cgp {
    my $R = shift;
    my $u = shift;
      my $c = {};
      if (!defined $u){
          $c->{undef} = 1;
      } else {
          if (my $ref = ref $u) {
              $c->{ARRAY} = 1 if $ref eq "ARRAY";
              $c->{HASH} = 1 if $ref eq "HASH";
              $c->{CODE} = 1 if $ref eq "CODE";
              $c->{canpi} = 1 if !%$c && $u->can('pi');
              for (qw'A C G T     R   J') {
                    $c->{$_} = 1 if $ref eq $_;
              }
              $c->{ref} = $ref;
          }
          else {
              if (ref \$u eq 'SCALAR') {
                  $c->{text} = 1;
                  $c->{len} = length($u);
                  $c->{lin} = scalar split /\n/, $u;
                  $c->{b} = scalar split /\n\n/, $u;
                  $c->{number} = $u =~ /^(?:\d+\.)?\d+$/;
                  $c->{wordy} = $u =~ /\w+/;
              }
              else { die "wtf is $u" };
          }
      }
      $c
}

sub phat {
    my $R = shift;
    my $a = shift;
     $a->{bb} = {};
     $a->{ord} = [];
     $a->{bz} = $R->as($a->{bb}, $a->{ord});
     $a->{fro} = sub {
         my $fro = [$a->{bz}, @_];
         $R->{G} ->w("gpfro", {a=>$fro}, $R);
     };
}

sub as {
    my $R = shift;
    my $bb = shift;
    my $ord = shift;
    my $j = {};
    my $do;
    $do = sub {
        my $j = {%$j};
        my $ad = [@_];
        my %j = %$j;
        while (@$ad) {
            my ($k, $v) = (shift @$ad, shift @$ad);

            my $comp = $k =~ /^(%|\+)/;
            my $j = {%j} if $comp;
            if ($comp) {
                $k =~ s/^\+// if $comp;
                $j->{t} .= $k if $comp;
            }
            else {
                ($j->{t}, $j->{cv}) = split /\s+/, $k, 2;
                %j = %$j;
            }
            $j->{cv} || die;
            $j->{r} = "$j->{t} $j->{cv}";
            $j->{s} = $v;
            $bb->{$j->{r}} = $j->{s};
            push @$ord, {%$j} if $ord;
        }
        sub{$do->(%$j, @_)}
    };
    $do
}

sub shj {
    my $R = shift;
    my ($r, $d) = @_;
    my $j;
    $j->{r} = $r;
    $j->{s} = ref $d eq 'HASH' ? $d->{$r} : $d; # carbon in
    ($j->{t}, $j->{cv}) =
        $j->{r} =~ /^(.+)\t(.+?)$/ ? ($1, $2)
        :
        split /\s+/, $j->{r}, 2;
    ($j->{cv}, my @e) = split /\s+/, $j->{cv};
    $j->{ev} = \@e if @e;
    $j
}

sub Jshonj {
    my $R = shift;
    my ($bb, $on) = @_;
    my @ksd = sort keys %$bb;
    my @j = map { $R->shj($_, $bb) } @ksd;

    if ($on) {
        my @on = sort { $a->{cv} <=> $a->{cv} } grep { $R->{G}->ip($on, $_) } @j;
        $on = {min => $on[0]->{cv}, max => $on[-1]->{cv}};
    }
    my $ji = 0;
    sub {
        my $j = $j[$ji++] || return;
        my $sec = 0;
        if ($on) {
            my $slike = $j->{cv} < $on->{min} ? $on->{min} : $on->{max};
            my $dist = $slike - $j->{cv};
            $dist *= -1 if $dist < 0;
            $dist = ceil($dist);
            $sec = $dist > 5 ? 0 : -$dist + 5;
        }
        ($j, $sec);
    }
}

9;

