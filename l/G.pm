package G;
use strict;
use utf8;
use base 'Ghost';

sub new {
    my $G = shift;
    my ($name, $O, @ways) = @_;
    
    $G->{GGs} = [];
    $G->{O} = $O; # TODO A
    
    $G->W || die "no Wormhole?";
    
    my $way = join ", ", @ways;
    $G->{name} = "$name`($way)";
    $G->{way} = $way;
    say "Ghost named $G->{name}";
    
    $G->load_ways(@ways);
    
    push @{$G->{O}->{GGs}}, $G if ref $G->{O} =~ /^G/;
    
    return $G;
}

sub A {
    my $G = shift;
    my $u = bless {}, shift;
    $G->{A}->t($u);
    $H->intro->($u);
    delete $u->{hostinfo};
    $u->new(@_);
}

sub W {
    my $G = shift;
    $G->{W} ||= $G->A('W')
}

'stylehouse'