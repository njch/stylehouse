package Babylon;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'view' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';

use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

# stuff from the old world
# can feel it already
# stuff we're going to take with us

# RSS: http://www.colorglare.com/feed.xml

# it's a join to other lumps of stuff that have what we need
# whole apps can start via procserv.pl
# we can build them apis in their own process like ebuge.pl
# this file's going to get huge but it's the right thing to do ;)
# turn this file into our old unconsciousness
# so we can watch ourselves wake up again and again

sub new {
    my $self = bless {}, shift;
    shift->($self);


    return $self;
}

sub menu {
    my $self = shift;
    my $menu = {
        guru => $self->hostinfo->send("\$('#hodi').css('background-image: url(\\\'http://24.media.tumblr.com/tumblr_lzsfutEA3G1rop013o1_1280.jpg\\\')');");
    };

    return $menu;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
    # chunk away the input
    # always able to hit space
    # tap out a vibe id :O
}



use Audio::MPD;
sub audio_mpd {
    my $babylon = shift;
    my $self = {
       mpd => Audio::MPD->new;

    }
    $mpd->play;
    sleep 10;
    $mpd->next;
}


sub youtube {
    my $babs = shift;
    my $video_id = shift || "PSNPpssruFY"; # Fats Waller - Aint Misbehavin
    my $iframe = '<iframe class="youtube-player" type="text/html" width="640" height="385" src="http://www.youtube.com/embed/'
        .$video_id.'" allowfullscreen frameborder="0"></iframe>';
    my $view = $babs->hostinfo->get_view($babs, "babs");
    $view->text->append([$iframe]); # here's where we attach a Ghost, once the concept emerges from other places
# Ghost is a server-side wiring for client side stuff we mirror
}

1;
package Lyrico;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use File::Slurp;
use Time::HiRes 'usleep';

has 'cd';
has 'pictures';
has 'hostinfo';
has 'text';
has 'view';
has 'started';
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
                $s->{class} = "pictures";
                $s->{value} = '<img src="'.$s->{value}.'">';
            }
        }, }
    ));

    $self->read_list;
    $self->write;

    return $self;
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
    my $spath = shift;
    my $picture = shift;
    $picture ||= $self->zlyrics;

    my $hooks = {};
    $hook->{spatialise} = sub { $spath } if $h;
    
    $self->text->spurt($picture, $hooks);
    return $self;
}

sub read_list {
    my $self = shift;
    $self->pictures([read_file("no_problem")]); # TODO stream God
}

sub startclicky {
    my $self = shift;
    $self->hostinfo->set('clickcatcher', $self);
    $self->hostinfo->send('$(window).scroll(clickyhand);');
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
        $h->{top} = $event->{pagey} + int  rand $height;
        $h->{left} = $event->{pagex};
        $h->{x} = ($i * 30) + int rand $height;
        my @lyrics = grep { s/\n//g; } grep /\S+/, map { $self->zlyrics } 1..3;
        $self->write($h, \@lyrics);
    }
}

sub menu {
    my $self = shift;
    return {
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
