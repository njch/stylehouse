package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Ghost';
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
    my $G = shift;
    my $d = shift;
    # ho$G->w("to", { %$ar }) get around the Objs' data
    my $du = dus();

    my $i = $_[0] || $T->{i};
    my $c = {};
    for my $k (keys %$i) {
        $c->{$k} = $i->{$k};
    }
    $c
    say "ETc";
}

sub dus {
    my $G = shift;
    Load(<<"");
      G:
        - lead to W which leads to Wsize

    #
}

'stylehouse'