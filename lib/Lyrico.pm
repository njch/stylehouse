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
my @texties;

my $i = 0;

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->view($self->hostinfo->get_view($self, "hodu"));
    $self->text($self->view->text([],
        { skip_hostinfo => 1,
        leave_spans => 1, 
        tuxts_to_htmls => sub {
            my $text = shift;
            for my $s (@{$text->tuxts}) {
                my $size = int rand 20;
                my $width = int rand 60;
                $s->{style} = random_colour_background()." opacity:0.4; font-size: ${size}em; width: ${width}em";
                $s->{class} = "lyrics";
            }
        }, }
    ));

    $self->lyrics([read_file("trampled_rose_lyrics")]);
    $self->hostinfo->send('$(window).scroll(clickyhand);');

    $self->hostinfo->set('clickcatcher', $self);
    return $self;
}

use Mojo::IOLoop;
sub event {
    my $self = shift;
    my $event = shift;
    my $height = $self->hostinfo->get("screen/height");
    $height ||= 900;
    my $h = {};

    say anydump($self->lyrics);

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
        my @lyrics = grep { s/\n//g; } grep /\S+/, map { $self->zlyrics } 1..3;
        $self->write($h, @lyrics);
    }
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
    $self->text->hooks->{spatialise} = sub { $h };
    say "Writing ".join(", ", @lyrics);
    $self->text->append([@lyrics]);
    return $self;
}

sub menu {
    my $self = shift;
    return {
        stop => sub {
            $self->hostinfo->unset('clickcatcher');
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

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

1;
