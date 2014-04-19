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
    my ($tid) = $id =~ /^(.+)(?:-\d+)?$/;
    my $value = $event->{value};


    my $texty = $self->ports->{menu}->text;
    
    #$self->hostinfo->flood({themenu => $texty, id => $id});

    my $app;
    my $menutuxt;
    my @seen;
    for my $tuxt (@{ $texty->tuxts }) {
        say "$id\t\t$tuxt->{id}\t\t$tuxt->{inner}->{id}";
        if ($tuxt->{id} eq $tid) {
            say "$tid is $tuxt->{origin}";
            $app = $tuxt->{origin};
            $menutuxt = $tuxt;
            last;
        }
        elsif ($tuxt->{inner}->{id} eq $tid) {
            say "$tuxt->{inner}->{id} ieq $id";

            return $self->hostinfo->updump($tuxt->{inner});

            next;
            say "texty nner:".ddump($tuxt->{inner});
            $app = $tuxt->{origin};
            $menutuxt = $tuxt;
            last;
        }
        say "$tuxt->{inner}->{id} ieq $id";

    }
    return $self->hostinfo->updump($app || $texty);
    
    if ($app) {
        my $menu = $app->menu();

        my $heardof = ref $app;
        if ($value =~ /^$heardof/) {
            unless ($menu->{'.'}) {
                return $self->hostinfo->error("$event->{id} found, object has no . menu item", $menutuxt);
            }
            $menu->{'.'}->($event);
        }
        unless ($menu->{'.'}) {
            return $self->hostinfo->error("can't find $value hook amongst ".join(", ",keys %$menu), $menutuxt);
        }
        $menu->{$value}->($event);
    }
    else {
        say "Nope wrong: ";
        #$self->hostinfo->updump($itemtexty);
    }
}

1;
