package Menu;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';
use Codo;
use FindBin '$Bin';

has 'hostinfo';
has 'ports';
has 'items';

my $i = 0;
sub view {
    my ($self, $view) = @_;
    $self->{view} ||= {};
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $view = $self->hostinfo->get_view($self, "menu");
    $view->text( [], {
        tuxts_to_htmls => sub {
            my $self = shift;
            my $h = $self->hooks;
            my $i = $h->{i} ||= 0;
            say "Doing some $self, tuxts=".@{$self->tuxts};
            for my $s (@{$self->tuxts}) {
                my $object = $s->{value};

                my $menu = $object->menu(); # we don't clobber this hash?
                delete $menu->{'.'};
                $s->{value} = "$object";
                $s->{value} =~ s/^(\w+).+$/$1/sgm;
                
                # generate another Texty for menu items
                # catch their <spans> and add to our value
                my $inner = new Texty($self->hostinfo->intro, $view, [ keys %$menu ], {
                    tuxts_to_htmls => sub {
                        my $self = shift;
                        my $i = $h->{i} || 0;
                        for my $s (@{$self->tuxts}) {
                            delete $s->{top};
                            delete $s->{left};
                            $s->{class} = 'menu';
                            $s->{style} .= random_colour_background();
                        }
                    },
                    notakeover => 1,
                });
                
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
                $s->{value} .= join "", @{$inner->htmls || []};
                $s->{inner} = $inner;
                $s->{origin} = $object;
                say ref $object." buttons: ".join ", ", @{ $inner->lines };
            }
        }
    });

    $self->make_menu();
    return $self;
}


sub make_menu {
    my $self = shift;
    
    if (!$self->ports) {
        say "Nein porten!";
        sleep 4;
        return $self;
    }
    my $v = $self->ports->{menu};


    my @items = $self->get_menu_items;
    
    say "Writing menu for ".join ", ", map { ref $_ } @items;

    $v->text->replace([@items], );

    say "Got out of there ok\n\n\n";

    $v->takeover($v->text->htmls);

    return $self;
}

sub menu {
    my $self = shift;
    return {
        blah => sub {
            $self->hostinfo->send_all;
        },
    };
}

sub get_menu_items {
    my $self = shift;

    my $apps = $self->hostinfo->get('apps');
    $apps = [ grep { $_->can('menu') } values $apps ];
    $self->items($apps);

    my @items;
    for my $item (@{ $self->items }) {
        if (ref $item) {
            push @items, $item;
        }
        else {
            my $got = $self->hostinfo->get($item);
            die "Not got $item" unless $got;
            push @items, $got;
        }
    }
    $self->items([@items]);
    @items;
    # make Texty[$item] hook to append menu items as more spans from another Texty
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

    say anydump($event);
    my $texty = $self->hostinfo->event_id_thing_lookup($event);
    if (!$texty) {
        $self->hostinfo->error("$event->{id} not found", [ $texty ]);
        return;
    }

    my ($itemtexty) = grep { $_->{id} eq $event->{id} } @{ $texty->tuxts };
    $self->hostinfo->updump($itemtexty);
    my $app = $itemtexty->{origin};
    my $value = $event->{value};
    
    if ($app) {
        my $menu = $app->menu();

        $self->hostinfo->updump($itemtexty);

        my $heardof = ref $app;
        if ($value =~ /^$heardof/) {
            unless ($menu->{'.'}) {
                return $self->hostinfo->error("$event->{id} found, object has no . menu item", $texty);
            }
            $menu->{'.'}->($event);
        }
        unless ($menu->{'.'}) {
            return $self->hostinfo->error("can't find $value hook amongst ".join(", ",keys %$menu), $texty);
        }
        $menu->{$value}->($event);
    }
    else {
        say "Nope wrong: ";
        $self->hostinfo->updump($itemtexty);
    }
}

1;
