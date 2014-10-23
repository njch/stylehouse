package G;
use strict;
use utf8;
use base 'Ghost';

sub new {
    my $G = shift;
    my $G = bless {}, shift;
    shift->($G); delete $self->{hostinfo};
    
    my ($name, $O, @ways) = @_;
    
    $G->{GGs} = []
    $G->{O} = $O; # TODO A
    
    $G->W || die "no Wormhole?";
    
    my $way = join ", ", @ways;
    $G->{name} = "$name`($way)";
    $G->{way} = $way;
    say "Ghost named $G->{name}";
    
    $G->load_ways(@ways);
    
    push @{$G->{O}->{GGs}}, $G if ref $G->{O} =~ /^G/;
    
    return $self;
}

'stylehouse'