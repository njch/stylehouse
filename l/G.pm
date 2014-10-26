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

    my $ref = ref $i;
    my $is = $s->{$ref} || $s->{default};
    $is ||= $s->{HASH} if "$i" =~ /^\w+=HASH\(/;
    $is ||= $s->{default} || return {};

    $a->{e} -= $is->{oh} || 1;

    for my $j ($is->{it}->($i)) {
        $c->{"$j->{k}"} = $j->{v};

        if ($a->{e} >= 1) {
            my $cu = du({%$a, i => $j->{v}});
            while (my ($k, $v) = each %$cu) {
                $c->{"$j->{k}".$k} = $v;
            }
        }
    }


    $c
}

sub dus {
    {
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
    }
}

'stylehouse'