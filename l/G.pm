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
    $G->load_ways(@ways);
    
    $G->{W} ||= $G->{A}->spawn0('W');
    $G->{name} ||= $G->{A}->path(name => 'G');
    
    $G
}

sub Av {
    my $G = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
    $G->{A}->t($u) if $G->{A}; # installs $u->{A}
    $H->intro->($u); # which replaces that
    delete $u->{hostinfo};
    $u->new(@_);
}

sub G {
    my $G = shift;
}

'stylehouse'