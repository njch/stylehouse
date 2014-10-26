package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Ghost';
sub wdump { Ghost::wdump(@_) };
sub gpty { Ghost::wdump(@_) };
sub sw { Ghost::sw(@_) };
use YAML::Syck;

sub new {
    my $G = shift;
    my (@ways) = @_;
    $G->{name} = join "+", @ways;

    $G->{W} ||= $G->{A}->spawn('W');

    $G->load_ways(@ways);

    $G
}

sub nw {
    my $G = shift;
    my $C = $G->{A}->spawn('C');
    $C->from({@_}) if @_;
    $C
}

sub load_ways {
    my $G = shift;
    my @ways = @_;
    $G->{ways} ||= [];
    $G->{wayfiles} ||= [];
    $G->{load_ways_count}++;

    my $ldw = [];
    while (defined( my $name = shift @ways )) {
        my @files;

        my $base = "ghosts/$name";
        push @files, $base if -f $base;
        push @files, grep { /\/\d+$/ } glob("$base/*");

        for my $file (@files) {
            # TODO pass an If object selector to 0->deaccum
            @{$G->{ways}} = grep { $_->{_wayfile} ne $file } @{$G->{ways}};
            @{$G->{wayfiles}} = grep { $_ ne $file } @{$G->{wayfiles}};

            my $nw = $G->nw(name=>$name);
            $nw->load($file);

            if (my $inc = $nw->{include}) {
                for my $name (split ' ', $inc) {
                    next if grep { $_->{name} eq $name } @{$G->{ways}};
                    push @ways, $name;
                }
            }

            say "G $G->{name} w+ $nw->{name}";
            push @{$G->{wayfiles}}, $file;
            push @{$G->{ways}}, $nw;
        }

        die "no wayfiles from $name" unless @files;
    }

    $G->_0('_load_ways_post', {w=>$G->{ways}});
}

sub du {
    my $a = shift;
    # ho$G->w("to", { %$ar }) get around the Objs' data
    my $s = $a->{s} ||= dus();
    my $i = $a->{i};
    my $n = $a->{n};
    $a->{e} = 2 if !defined $a->{e};

    my $c = {};
    $a->{as} ||= [];
    die sw($a) if !defined $a->{i};
    push @{$a->{as}}, $a;
    $a->{ds} = [@{$a->{ds}||[]}, $a];

    return {} if @{$a->{ds}} > 12 || 2 < grep {ref $_->{i} && $_->{i} eq $i} @{$a->{as}};

    my $ref = ref $i;
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    # may someday zip into dus again for HASH key importance
    # data as fractions of energy that enlightens what kus
    # $an->{s} can be modded as meaning builds down
    my $mustb = { map { $_ => 1 } split ',', $is->{mustb} } if $is->{mustb};

    for my $j ($is->{it}->($i)) {
        my $k = delete $j->{k};
        my $v = delete $j->{v};

        #$c->{$k} = $v;
        my $rk = $k." e=$a->{e}";
        $c->{$rk} = $v;

        next if !ref $v;

        $j = {%$is, %$j};
        my $an = {%$a, i => $v};

        my $ohms = defined $j->{oh} ? $j->{oh} : 1;

        $an->{e} -= $ohms;

        delete $c->{$rk};
        $rk .".. $an->{e}";
        $c->{$rk} = $v;

        say join("", ("  ") x scalar(@{$a->{ds}}))
            ." $a->{e} - $ohms  $k\t $an->{e} \t\t ".Ghost::gpty($i);

        if ($an->{e} >= 1) {
            my $cu = du($an);
            while (my ($ku, $vu) = each %$cu) {
                $c->{$k.$ku} = $vu;
            }
        }
        elsif ($an->{e} > 0 && $an->{e} < 1 && $mustb){# && !$mustb->{$k}) {
            $c->{$rk} = '-------';
            die sw($mustb);
        }
            die sw([$mustb, $an->{e}]) if $mustb;
    }


    $c
}

sub dus {
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
          map { { k => "{".$_, v => $h->{$_} } } sort keys %$h
        },
      },
    };
    my $an = sub {
        my $k = shift;
        my $i = $h->{$k} ||= {it => $h->{HASH}->{it}};
        %$i = (%$i, @_);
    };
    $an->(qw'A oh 2.8');
    $an->(qw'Ghost oh 0.8');
    $an->(qw'G oh 0.8');
    $an->(qw'W oh 0.8 mustb id,hash,file,G');
    $h
}

'stylehouse'