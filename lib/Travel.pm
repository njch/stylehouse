package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    return $self;
}


# stack of ghosts...
sub travel {
    my $self = shift;
    my $thing = shift;
    my $ghost = shift || new Ghost($self->hostinfo->intro, $self);
    my $way = shift;
    my $depth = shift || 0;

    say " travel! - " if !$depth;

    my $away = $ghost->haunt($depth, $thing, $way);

    if (!@$away) {
        return "";
    }

    for my $c (@$away) {
        if (my $t = $c->{travel}) {
            $self->travel($t->{thing}, $ghost, $t->{way}, $depth+1);
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
