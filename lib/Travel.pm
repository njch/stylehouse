package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);
    my $self->{hooks} = shift;

    return $self;
}


# stack of ghosts...
sub travel {
    my $self = shift;
    my $thing = shift;
    my $ghost = shift || new Ghost($self->hostinfo->intro, $self);
    my $way = shift;
    my $depth = shift || 0;

    my $away = $ghost->haunt($thing, $way);

    if (!@$away) {
        return "";
    }

    for my $c (@$away) {
        if (my $t = $c->{travel}) {
            $self->travel($t->{thing}, $ghost, $t->{way}, $depth+1);
        }
    }

    my $script = $ghost->{wormhole}->{script};
    return @$script;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
