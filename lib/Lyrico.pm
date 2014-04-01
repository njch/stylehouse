package Lyrico;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'cd';
has 'lyrics';
has 'hostinfo';
my @texties;

my $i = 0;

sub new {
    my $self = bless {}, shift;

    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    my $lyrics = capture("cat", "trampled_rose_lyrics");
    $self->lyrics([split "\n", $lyrics]);
    $self->hostinfo->send('$(window).scroll(clickyhand);');

    $self->hostinfo->set('eventcatcher', $self);
    return $self;
}
sub menu {
    my $self = shift;
    return {
        stop => sub {
            $self->hostinfo->unset('eventcatcher');
            $self->hostinfo->send("\$('#view span').remove();");
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
sub zlyrics {
    my $self = shift;
    my $lyrics = $self->lyrics;
    $i++;
    unless (exists $lyrics->[$i]) {
        $i = 0;
    }
    return $lyrics->[$i];
}

sub write {
    my $self = shift;
    my $h = shift;
    my @lyrics = @_;
    my $text = new Texty($self, [@lyrics], {
        view => "hodu",
        leave_spans => 1,
    });
    for my $s (@{$text->spans}) {
        my $size = int rand 20;
        my $width = int rand 60;
        $s->{style} = random_colour_background()." opacity:0.4; font-size: ${size}em; width: ${width}em";
        $s->{class} = "lyrics";
    }
    $text->spatialise($h);
    $text->spans_to_jquery();
    $text->send_jquery();
    push @texties, $text;
    return $self;
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
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
        $h->{top} = $event->{pagey} + int  rand $height;
        $h->{left} = $event->{pagex};
        $h->{x} = ($i * 30) + int rand $height;
        my @lyrics = map {$self->zlyrics} 1..3;
        $self->write($h, @lyrics);
    }
}

1;
