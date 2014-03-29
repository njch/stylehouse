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

    $self->hostinfo->tx->send("\$(window).on('click', clickhand);");
    $self->hostinfo->set('Menu', $self);
    $self->items([
        $self->hostinfo->get('Lyrico'),
        $self->hostinfo->get('Direction'),
    ]);
    $self->write;
    return $self;
}
sub write {
    my $self = shift;
    my $h = shift;
# inflate the value to the module name + more spans
    my $text = new Texty($self, $self->items, {
        view => "menu",
        skip_hostinfo => 1,
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
                            my ($rgb) = join", ", map int rand 255, 1 .. 3;
                            $s->{style} .= "background: rgb($rgb);";
                        }
                    },
                    catch_span_htmls => sub {
                        my $self = shift;
                        push @htmls, @_;
                    },
                });
                
                my ($rgb) = join", ", map int rand 255, 1 .. 3;
                $s->{style} = "background: rgb($rgb);";
                $s->{class} = 'menu';
                $s->{value} .= " @htmls ";
            }
        }
     });
    say "Done?";
    return $self;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $height = $self->hostinfo->get("screen/height");
    $height ||= 900;
    my $h = {};
    if ($event->{y} < 40) {
        my @js;
        if ($event->{x} < 100) {
            $self->hostinfo->set("Ballz $event->{x}");
        }
        new Dumpo($self);
        $tx->send(join "\n", @js);

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
