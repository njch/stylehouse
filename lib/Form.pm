package Form;
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

    $menu->{is} = sub { $self->inject_space };

    return $menu;
}

# everything that exists on the screen is part of the experience
# the useful way our brains work is injecting space into ideas, or just being
sub inject_space {
    my $self = shift;
    my $geo = shift;

    my $stuff = $self->hostinfo->get_goya(); # it's almost never a concept you get to play with on its own

    # the rest of this is up to innovation, finally
    my %spans_by_x;
    my %spans_by_y;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
