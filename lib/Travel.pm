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

    $self->{name} = shift; # id instead of link, is wrong at the next level

    return $self;
}


# stack of ghosts...
sub travel {
    my $self = shift;
    my $thing = shift;
    my $ghost = shift || $self->hostinfo->get_ghost($self);
    say "The Ghost: ".Hostinfo::ddump($ghost);
    my $way = shift;
    my $depth = shift || 0;
    my $last_state = shift;

    say " travel! - " if !$depth;

    my ($state, $away) = $ghost->haunt($depth, $thing, $way, $last_state);

    if (!@$away) {
        return "";
    }

    for my $c (@$away) {
        if (my $t = $c->{travel}) {
            $self->travel($t->{thing}, $ghost, $t->{way}, $depth+1, $state);
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
