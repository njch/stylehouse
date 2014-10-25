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
}

'stylehouse'