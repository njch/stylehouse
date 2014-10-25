package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use base 'Ghost';

sub new {
    my $G = shift;
    my (@ways) = @_;
    $G->{name} = join "+", @ways;
    
    $G->{W} ||= $G->{A}->spawn('W');
    
    $G->load_ways(@ways);
    
    $G
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
        push @files, glob($base),
            grep { /\/\d+$/ } glob("$base/*");
        die "$base -> ".join", ", @files;
    
        for my $file (@files) {
            # TODO pass an If object to 0->accum
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
    
        if (@files) {
            $H->watch_ghost_way($G, $name, \@files);
        }
        else {
            $H->error("No way! $name");
        }
    }
    
    $G->_0('_load_ways_post', {w=>$G->{ways}});
}

'stylehouse'