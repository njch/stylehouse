package Keys;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'view' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
has 'gear';
has 'started';

use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub new {
    my $self = bless {}, shift;
    shift->($self);

    return if $self->hostinfo->get("Keys");

    $self->gear($self->hostinfo->get_view($self, "hodu"));

    say "Made keys";
    return $self;
}

sub start {
    my $self = shift;
    
    $self->started(1);
    $self->gear->text(
        ['<form action="#"><textarea rows="1" cols="20" id="Keys"></textarea></form>'],
        { spatialise => sub {
            return { top => '50%', right => 20 }
        }, },
    );
}

sub stop {
    my $self = shift;
    
    $self->started(1);
    $self->gear->nah;
    $self->gr;
}

# garbage robot
sub gr {
    my $self = shift;
}

sub menu {
    my $self = shift;
    my $menu = {
        '.' => sub {
            if ($self->started) {
                $self->stop;
            }
            else {
                $self->start;
            }
        },
    };

    return $menu;
}



sub event {
    my $self = shift;
    my $event = shift;
    #blah
    # chunk away the input
    # always able to hit space
    # tap out a vibe id :O
}

1;
