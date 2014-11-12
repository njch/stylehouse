package R;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
sub new {
    my $R = shift;
    $R->{name} = shift;

    $R
}

sub pi {
    my $R = shift;
    "R $R->{name}"
}

sub du {
    my $R = shift;
    my $a = shift;
    die G::sw($a) if !defined $a->{i};
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

    my $ref = ref $i;
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    # sw is a channel
    # the way in the splat...

    # snapping branches off the concept of ^ for now

    # we sculpt data as fractions of energy that enlightens the 1-9 meanings

    # $an->{s}, etc can be modded as meaning builds down
    # but only for 
    # (separado until much future brings everything together)

    my $mustb = { map { $_ => 1 } split ',', $is->{mustb} } if $is->{mustb};

    for my $j ($is->{it}->($i)) {
        my $k = delete $j->{k};
        my $K = delete $j->{K};
        my $v = delete $j->{v};

        $j = {%$is, %$j};
        my $an = {%$a, i => $v};

        my $ohms = defined $j->{oh} ? $j->{oh} : 1;

        $an->{e} -= $ohms;

        my $rk = "$k $an->{e}";
        $c->{$rk} = $v;

        say join("", ("  ") x scalar(@{$a->{ds}}))
            ." $a->{e} - $ohms  $k\t $an->{e} \t\t ".Ghost::gpty($v);

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


    $c
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
    $an->(qw'A oh 0.2');
    $an->(qw'Ghost oh 0.8');
    $an->(qw'G oh 0.8');
    $an->(qw'W oh 0.8 mustb','id,hash,file,G');
    $h
}

'stylehouse'