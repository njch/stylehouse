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
sub queue_update {
    my $self = shift;
    return if $self->{queue_update};
    
        my $delay = Mojo::IOLoop::Delay->new();
        $delay->steps(
            sub { Mojo::IOLoop->timer(1 => $delay->begin); },
            sub { $self->lines_to_tuxts(); },
        );
}
sub new {
    my $self = bless {}, shift;
    shift->($self);
    
    $DB::single = 1;
    $self->hostinfo->get_view($self, "menu");
    usleep 250;

    $self->write;
    return $self;
}
sub menu {
    my $self = shift;
    return {
        blah => sub {
            Codo->new($self->hostinfo->intro) unless $Bin=~/test/;
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
    @items;
    # make Texty[$item] hook to append menu items as more spans from another Texty
}

sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^    /,
        split "\n", anydump($thing);
}

sub write {
    my $self = shift;
    my $h = shift;
    
    usleep 250;
    
    

    usleep 25000;
    if (!$self->ports) {
        sleep 4;
        return $self;
    }
    my $v = $self->ports->{menu};

    $v->text();
    say "HTMLS: ".anydump($v->text->htmls);

    my @items = $self->get_menu_items;
    say "Items: ".ddump(\@items);

    $v->text->replace([@items], {
        tuxts_to_htmls => sub {
            my $self = shift;
            my $i = $h->{i} || 0;
            say "Doing some $self";
            for my $s (@{$self->tuxts}) {
                my $object = $s->{value};

                my $menu = $object->menu();
                say "emnu: ". anydump($menu);
                $s->{value} = "$object";
                $s->{value} =~ s/^(\w+).+$/$1/sgm;
                
                # generate another Texty for menu items
                # catch their <spans> and add to our value
                my $inner = new Texty($self->hostinfo->intro, "...", $v, [ keys %$menu ], {
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
    say "Got out of there ok\n\n\n";

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
        say "Is a: ".ddump($mob);
        $mob->{$value}->($event);
    }
    else {
        say "Nope wrong: ";#anydump([$object, $self]);
    }
}

1;
