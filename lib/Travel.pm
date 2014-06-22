package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;
sub ddump { Hostinfo::ddump(@_) }
has 'cd';
has 'hostinfo';
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{owner} = shift; # id instead of link, is wrong at the next level
    $self->{name} = $self->{owner}->{name} || $self->{owner}->{id};

    return $self;
}
sub G {
    my $self = shift;
    $self->{ghost} ||= new Ghost($self->hostinfo->intro, $self, @_);
}
sub W { shift->G->W }

# back here again
# the wormhole for self
# what's a wormhole of ghosts? hookways mixes ways

# the wormhole for self
# so G can make harmonic W inside a singular T

# the wormhole for self
# so G can make harmonic W inside a singular T

# the wormhole for self
# so G can make harmonic W inside a singular T
# self awareness

# the wormhole for self
# so G can make harmonic W inside a singular T
# self awareness

# the wormhole for self
# so G can make harmonic W inside a singular T
# self awareness

# the wormhole for self
# so G can make harmonic W inside a singular T
# self awareness
sub ob {
    my $self = shift;
    return if ref $self->{owner} eq "Travel";
    my @seen = @_;
    $self->{hostinfo}->enlogform(@seen);

    $self->{self}->travel($ob);

    push @{ $self->hostinfo->gest("Codo/obsetrav", []) }, $ob;
}
sub travel {
    my $self = shift;
    my $t = shift;
    my $G = shift || $self->G;
    my $i = shift;
    my $depth = shift || 0;
    my $last_state = shift;

    $self->ob(($depth ? "..travel..." : "travel!") => $thing);

    say "Travel to $thing";
    my ($last, $away) = $G->haunt($depth, $t, $i, $last_state);

    for my $c (@$away) {
        if (my $t = $c->{travel}) {
            #say join(("  ")x$depth)."  away to: $t->{thing}";
            $self->travel($t->{thing}, $ghost, $t->{way}, $depth+1, $last);
        }
    }

    return $ghost->{wormhole};
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

