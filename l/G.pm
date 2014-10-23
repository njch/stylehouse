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
    my ($name, $O, @ways) = @_;
    
    $G->{GGs} = [];
    $G->{O} = $O; # TODO A
    
    $G->{W} ||= $G->A('W') || die "no Wormhole?";
    
    my $way = join ", ", @ways;
    $G->{name} = "$name`($way)";
    $G->{way} = $way;
    say "Ghost named $G->{name}";
    
    $G->load_ways(@ways);
    
    push @{$G->{O}->{GGs}}, $G if ref $G->{O} =~ /^G/;
    
    $G
}

sub A {
    my $G = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
    $G->{A}->t($u) if $G->{A}; # installs $u->{A}
    $H->intro->($u); # which replaces that
    delete $u->{hostinfo};
    $u->new(@_);
}

'stylehouse'