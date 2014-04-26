package Menu;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';
use Codo;
use FindBin '$Bin';

has 'hostinfo';
has 'view';
has 'text';
has 'items';

my $i = 0;
sub view {
    my ($self, $view) = @_;
    $self->{view} ||= {};
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->view(shift);
    
    # pick apart spec for us & our texty
    $self->{hooks} = shift;

    $self->{text} = new Texty($self->hostinfo->intro, $self->view, [], $self->{hooks});

    return $self;
}

sub replace {
    my $self = shift;

    my $items = shift;

    say "Writing menu for ".join ", ", map { ref $_ } @$items;

    $self->text->replace([@$items]);

    $self->view->takeover($self->text->htmls);

    return $self;
}

use YAML::Syck;
sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^     /,
        split "\n", Dump($thing);
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub event {
    my $self = shift;
    my $event = shift;
    my $height = $self->hostinfo->get("screen/height");
    $height ||= 900;
    my $h = {};

    # get this event to go to the right object
    my $id = $event->{id};
    my $value = $event->{value};

    my $texty = $self->text;
    my $dest;
    my $method;
    for my $tuxt (@{ $texty->tuxts }) {
        if ($tuxt->{id} eq $id) {
            $dest = $tuxt->{origin};
            $method = ".";
            last;
        }
        say "This tuxt: ".ddump($tuxt);
        for my $subtuxt (@{ $tuxt->{inner}->tuxts }) {
            if ($subtuxt->{id} eq $id) {
                $dest = $tuxt->{origin};
                $method = $subtuxt->{value};
                last;
            }
        }
    }
    
    if ($dest) {
        my $menu = $dest->menu();
        unless ($menu->{$method}) {
            say "Menu for $dest has no $method";
            return;
        }
        $menu->{$method}->($event);
    }
    else {
        say "Nope wrong: ";
        $self->hostinfo->flood($texty);
    }
}

1;
