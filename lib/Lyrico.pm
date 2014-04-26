package Lyrico;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use File::Slurp;
use Time::HiRes 'usleep';

has 'cd';
has 'lyrics';
has 'hostinfo';
has 'text';
has 'view';
has 'started';
my @texties;

my $i = 0;

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->view($self->hostinfo->get_view($self, "lyrics" => "hodi"));
    $self->text($self->view->text([],
        { skip_hostinfo => 1,
        leave_spans => 1, 
        tuxts_to_htmls => sub {
            my $text = shift;
            for my $s (@{$text->tuxts}) {
                my $size = int rand 20;
                my $width = int rand 60;
                $s->{style} = random_colour_background()." opacity:0.4; font-size: ${size}em; width: ${width}em"
                    .($size > 10 ? "font-family: Cambria, Georgia, serif;" : "");
                $s->{class} = "lyrics";
            }
        }, }
    ));

    $self->lyrics([read_file("trampled_rose_lyrics")]);

    $self->startclicky;

    return $self;
}

sub startclicky {
    my $self = shift;
    $self->hostinfo->set('clickcatcher', $self);
#    $self->hostinfo->send('$(window).scroll(clickyhand);');
    $self->started(1);
}
sub stopclicky {
    my $self = shift;
    $self->hostinfo->unset('clickcatcher');
    $self->hostinfo->send("\$('.lyrics').remove();");
    $self->started(0);
}
use Mojo::IOLoop;
sub event {
    my $self = shift;
    my $event = shift;
    my $height = $self->hostinfo->get("screen/height");
    $height ||= 900;
    my $h = {};

    if ($event->{type} eq "scroll") {
        if ($self->{scroll_throttle}) {
            return;
        }
        $self->{scroll_throttle} = 1;
        Mojo::IOLoop->timer(0.2, sub {
            $self->{scroll_throttle} = 0;
        });
    }

    for (1..3) {
        $h->{top} = $event->{pagey} + int  rand $height; # isn't y coming from below?
        $h->{left} = $event->{pagex};
        $h->{x} = ($i * 30) + int rand $height;
        my @lyrics = grep { s/\n//g; } grep /\S+/, map { $self->zlyrics } 1..3;

        if (grep { /love/ } @lyrics) {
            if (my $pictures = $self->hostinfo->get("Pictures")) {
                $pictures->write($h);
                return;
            }
        }

        $self->write($h, \@lyrics);
    }
}

sub zlyrics {
    my $self = shift;
    my $lyrics = $self->lyrics;
    $i++;
    unless (exists $lyrics->[$i]) {
        $i = 0;
    }
    my $ly = $lyrics->[$i];
    return $ly;
}

sub write {
    my $self = shift;
    my $h = shift;
    my $lyrics = shift;
    
    $self->text->spurt($lyrics, { spatialise => sub { $h } });
    return $self;
}

sub menu {
    my $self = shift;
    return {
        '.' => sub {
            $self->hostinfo->flood($self->{text});
        },
        onoff => sub {
            if ($self->started) {
                $self->stopclicky;
            }
            else {
                $self->startclicky;
            }
        },

        anim => sub {
            my @js;
            for my $t (@texties) {
                next;
                my $id = $t->lines->[0]->{id};
                my $x = $t->lines->[0]->{left};
                if (int(rand 1)) {
                    $x *= 0.3;
                }
                else {
                    $x *= 2;
                }

                push @js, "\$('#$id').animate({left: 400}, 5000, 'swing');"
            }
            $self->hostinfo->send(join "\n", @js);
        },
    };
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

1;
