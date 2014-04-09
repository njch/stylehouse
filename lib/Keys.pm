package Keys;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'view' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';

use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub new {
    my $self = bless {}, shift;
    shift->($self);

    return if $self->hostinfo->get("Keys");

    $self->hostinfo->get_view($self, "hodu")->text(
        ['<form action="#"><textarea rows="1" cols="20" id="Keys"></textarea></form>'],
        { spatialise => sub {
            return { top => 30, right => 20 }
        }, },
    );

    return $self;
}

sub menu {
    my $self = shift;
    my $menu = {};

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
