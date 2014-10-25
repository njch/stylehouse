package G;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use base 'Ghost';
use feature 'say';

sub new {
    my $G = shift;
    my (@ways) = @_;
    
    $G->{name} ||= $G->{A}->path(name => 'G');
    
    $G->{W} ||= $G->{A}->spawn0('W');
    
    $G->load_ways(@ways);
    
    $G
}

sub Av {
    my $G = shift;
}

'stylehouse'