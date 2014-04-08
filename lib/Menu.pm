package Menu;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'hostinfo';
has 'view' => sub { {} };
has 'items';

my $i = 0;

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, "menu");

    $self->write;
    return $self;
}
sub menu {
    my $self = shift
    return {
        blah => sub { },
    };
}
sub write {
    my $self = shift;
    my $h = shift;

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
    push @items, $self;
    $self->items([@items]);
    # make Texty[$item] hook to append menu items as more spans from another Texty

    for my $item (@{ $self->items }) {

        $self->view->{menu}->text([$item], {
            view => "menu",
            tuxts_to_htmls => sub {
                my $self = shift;
                my $i = $h->{i} || 0;
                for my $s (@{$self->tuxts}) {
                    my $object = $s->{value};

                    my $menu = $object->menu();
                    $s->{value} = "$object";
                    $s->{value} =~ s/^(\w+).+$/$1/sgm;
                    
                    # generate another Texty for menu items
                    # catch their <spans> and add to our value
                    my $inner = new Texty($self->hostinfo->intro, "...", $self->view, [ keys %$menu ], {
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
                    $s->{value} .= join "", @{$inner->htmls};
                    $s->{inner} = $inner;
                }
            }
         });
    }
    return $self;
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

    my $object = $self->hostinfo->event_id_thing_lookup($event);
    if (!$object) {
        $self->hostinfo->send("console.log('$event->{id} not found')");
    }
    my $ownerowner = $object->view->text->lines->[0];
    my $value = $event->{value};
    
    my ($menuobject) = grep { $_ eq $ownerowner } @{ $self->items };
    if ($menuobject) {
        my $mob = $menuobject->menu();
        $mob->{$value}->($event);
    }
    else {
        say "Nope wrong: ";#anydump([$object, $self]);
    }
}

1;
