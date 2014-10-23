package G;
use strict;
use utf8;
use base 'Ghost';
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo}; # TODO put this back once travelling feels right

    my $name = shift;
    if (ref $name eq "Travel") {
        $self->{T} = $name;
        $name = $name->{name};
    }
    
    $self->W || die "no Wormhole>?";
    
    $self->{O} = $self->{T}->{O};
    $self->{GGs} = [];
    
    my @ways = @_;
    say "way spec @_";
    unless (@ways) {
        my $s = { map { $_ => (/^(\w)/)[0] }
            qw{Ghost Hostinfo Travel Wormhole} };
        
        my $guess = ref $self->{T}->{O};
        $guess = $s->{$guess} if $s->{$guess};
        say " . . guess way is $guess";
        @ways = $guess;
    };
    my $way = join ", ", @ways;
    $name = "$name`($way)";
    $self->{name} = $name;
    $self->{way} = $way;
    say "Ghost named $name";
    $self->load_ways(@ways);
    
    if (ref $self->{T}->{O} eq "Ghost") {
        push @{$self->{T}->{O}->{GGs}}, $self;
    }
    

    return $self;
}

1;

