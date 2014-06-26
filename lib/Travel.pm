package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;
sub ddump { Hostinfo::ddump(@_) }
has 'cd';
our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};

    my @from = @_;
    ($self->{O}) = @from;
    $self->{from} = \@from;
    $self->{name} = $self->{O}->{name} || $self->{O}->{id};

    return $self;
}
sub G {
    my $self = shift;
    $self->{G} ||= new Ghost($H->intro, $self, @_);
}
sub W {
    shift->G->W
}
sub ob {
    my $self = shift;
    return unless $self->{TT};
    
    my $ob = $H->enlogform(@_); # describes stack, etc
# we want to catch runaway recursion from here
    $self->{TT}->travel($ob);
}

# the wormhole for self
# so G can make harmonic W inside a singular T
# self awareness
sub travel {
    my $self = shift;
    my $t = shift;
    my $G = shift || $self->G;
    my $i = shift;
    my $depth = shift || 0;
    my $last_line = shift;

    $self->ob("Travel", $depth, $t);
    say "Travel to ".($t||"~");
    
    my ($line, $o) = $G->haunt($depth, $t, $i, $last_line);

    for my $c (@$o) {
        if (exists $c->{travel_this}) {
            $self->travel($c->{travel_this}, $G, $c, $depth+1, $line);
        }
        else {
            die "what kind of way out is ".ddump($c);
        }
    }

    return $G->{wormhole};
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

