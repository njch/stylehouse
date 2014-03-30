package Menu;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'hostinfo';
has 'items';

my $i = 0;

sub new {
    my $self = bless {}, shift;

    $self->hostinfo(shift->hostinfo);

    $self->hostinfo->set('Menu', $self);
    $self->items([
        $self->hostinfo->get('Lyrico'),
#        $self->hostinfo->get('Direction'),
        $self->hostinfo->get('Dumpo'),
    ]);
    $self->write;
    return $self;
}
sub write {
    my $self = shift;
    my $h = shift;
# inflate the value to the module name + more spans
    for my $item (@{ $self->items }) {

        my $text = new Texty($self, [$item], {
            view => "menu",
            spans_to_jquery=> sub {
                my $self = shift;
                my $i = $h->{i} || 0;
                for my $s (@{$self->spans}) {
                    my $object = $s->{value};

                    my $menu = $object->menu();
                    $s->{value} = "$object";
                    $s->{value} =~ s/^(\w+).+$/$1/sgm;
                    
                    # generate another Texty for menu items
                    # catch their <spans> and add to our value
                    my @htmls;
                    $self->hostinfo->send("console.log('Text $s->{id}')");
                    my $ob_menu_texty = new Texty($self, [ keys %$menu ], {
                        view => $s->{id},
                        notx => 1,
                        spans_to_jquery => sub {
                            my $self = shift;
                            my $i = $h->{i} || 0;
                            for my $s (@{$self->spans}) {
                                delete $s->{top};
                                delete $s->{left};
                                $s->{class} = 'menu';
                                $s->{style} .= random_colour_background();
                            }
                        },
                        catch_span_htmls => sub {
                            my $self = shift;
                            push @htmls, @_;
                        },
                    });
                    
                    $s->{style} = random_colour_background();
                    $s->{class} = 'menu';
                    $s->{value} .= " @htmls ";
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
    if ($event->{y} < 40) {
        if ($event->{x} < 100) {
            $self->hostinfo->set("Ballz $event->{x}");
        }
        my $object = $self->hostinfo->event_id_thing_lookup($event);
        if (!$object) {
            $self->hostinfo->send("console.log('$event->{id} not found')");
        }
        my $ownerowner = $object->owner->lines->[0];
        my $value = $event->{value};
        say "Ya click $value <- $ownerowner";
        my ($menuobject) = grep { $_ eq $ownerowner } @{ $self->items };
        if ($menuobject) {
            my $mob = $menuobject->menu();
            $menuobject->menu->{$value}->($event);
        }
        else {
            say "Nope wrong: ";#anydump([$object, $self]);
        }


    } else {
        $h->{tp} = $event->{y};
        $h->{lp} = $event->{x};
        for my $i (1..1) {
            usleep 250;
            $h->{x} = ($i * 30) + int rand $height;
            $self->write($h) for 1..7;
        }
    }
}

1;
