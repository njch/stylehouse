package Lyrico;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use File::Slurp;
use Time::HiRes 'usleep';

my $i = 0; # sweeps through @{lyrics}

$Hostinfo::data->{'horizon'} =
    $Hostinfo::data->{style} eq
"stylehouse"?
"50%"
:
#"89.91%"
"39%"
;

$Hostinfo::data->{'flood/default_thing'} = "Yoyoyoyoy"; #$Hostinfo::data;


sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{hostinfo}->create_view($self, "lyrico" => "height: 2px; width: 2px;");
    $self->{lyrico}->text([],
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
    );

    $self->{lyrics} = [read_file("trampled_rose_lyrics")];
    
    $self->{wormhola} = $self->{hostinfo}->{sky}->spawn_floozy(
        ra => "width:50%; border: 2px dotted green; color: black; height: 100%; opacity: 0.8; overflow: scroll;"
    );

    $self->{T} = Travel->new($self->{hostinfo}->intro, $self);

    $self->somewhere() if $self->{hostinfo}->get("style") ne "stylehouse";

    return $self;
}


sub somewhere {
    my $self = shift;

    my $what = $self->{lyrics};
    $what = ['!'];
    $self->{hostinfo}->ravel(
        $self->{T},
        $what,
        $self->{wormhola}
    );

    $self->{hostinfo}->timer(2, sub {
        $self->somewhere();
    }) if 0 && $self->{hostinfo}->get("style") ne "stylehouse";
}


sub menu {
    my $self = shift;
    return {
        '.' => sub {
            $self->{hostinfo}->flood($self->{text});
        },
        TRAVEL => sub {
            $self->somewhere;
        },
        onoff => sub {
            $self->{started} ? $self->stopclicky : $self->startclicky
        },
        C => sub {
            Git->new($self->{hostinfo}->intro);
            Codo->new($self->{hostinfo}->intro);
        },
        anim => sub {
            $self->hostinfo->send("\$('.".$self->{lyrico}->{divid}."').animate({left: 400}, 5000, 'swing');");
        },
    };
}
sub event {
    my $self = shift;
    my $event = shift;
    my $height = $self->{hostinfo}->get("screen/height");
    $height ||= 900;
    my $h = {};

    for (1..3) {
        $h->{top} = $event->{pagey} + int  rand $height; # isn't y coming from below?
        $h->{left} = $event->{pagex};
        $h->{x} = ($i * 30) + int rand $height;
        my @lyrics = grep { s/\n//g; } grep /\S+/, map { $self->zlyrics } 1..3;

        if (grep { /love/ } @lyrics) {
            if (my $pictures = $self->{hostinfo}->get("Pictures")) {
                $pictures->write($h);
            }
        }

        $self->write($h, \@lyrics);
    }
}


sub startclicky {
    my $self = shift;
    $self->{hostinfo}->set('clickcatcher', $self);
    $self->{started} = 1;
}


sub stopclicky {
    my $self = shift;
    $self->{hostinfo}->unset('clickcatcher');
    $self->{hostinfo}->send("\$('.lyrics').remove();");
    $self->{started} = 0;
}



sub zlyrics {
    my $self = shift;
    my $lyrics = $self->{lyrics};
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
    
    $self->text->spurt($lyrics, { spatialise => sub { $h } }); # TODO fix spurt

    return $self;
}

use Mojo::IOLoop;


sub scroll_unthrottle {
    my $self = shift;
    $self->{scroll}->{throttle} = 0;
    if ($self->{scroll}->{latest}) {
        $self->scroll(delete $self->{scroll}->{latest});
    }
}


sub scroll_throttle {
    my $self = shift;
    my $s = shift;
    if ($self->{scroll}->{throttle}) {
        $self->{scroll}->{latest} = $s;
        return 1;
    }
    $self->{scroll}->{throttle} = 1;
    $self->{scroll}->{latest} = $s;
    Mojo::IOLoop->timer(0.2, sub {
        $self->scroll_unthrottle;
    });
    return 0;
}



sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

1;
