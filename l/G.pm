package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Ghost';
sub wdump { Ghost::wdump(@_) };
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
    $a->{e} ||= 2;

    my $c = {};
    push @{$a->{as}||=[]}, $a;
    return {} if @{$a->{as}} > 9 || 1 < grep {ref $_->{i} && $_->{i} eq $i} @{$a->{as}};

    my $ref = ref $i;
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    for my $j ($is->{it}->($i)) {
          die if !$j;
        my $k = delete $j->{k};
        my $v = delete $j->{v};

        $c->{$k} = $v;

        $j = {%$is, %$j};
        my $an = {%$a, i => $v};

        $an->{e} -= $j->{oh} || 0.5; # ohms
        say "$k j oh $j->{oh}\t-> $an->{e}" if $j->{oh};


        if ($an->{e} >= 1) {
            my $cu = du($an);
            # may someday zip into dus again for fractions
            # to display only 2
            # $an->{s} can be modded from above as meaning builds up
            # then lookup which kus to grab all the way up to $an->{e}
            while (my ($ku, $vu) = each %$cu) {
                $c->{$k.$ku} = $vu;
            }
        }
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
      },
      HASH => {
        it => sub {
          my $h = shift;
          map { { k => "{".$_, v => $h->{$_} } } sort keys %$h
        },
      },
    };
    $h->{A} = { it => $h->{HASH}->{it},
      oh => 2.8,
    };
    $h->{Ghost} = { it => $h->{HASH}->{it},
      oh => 2.8,
    };
    $h
}

'stylehouse'