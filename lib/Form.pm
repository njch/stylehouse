package ;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;


has 'hostinfo';
has 'view' => sub { {} };

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, "hodu")->text(
        ['<form action="#"><input type="text" name="action"></form>'],
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
}

1;
