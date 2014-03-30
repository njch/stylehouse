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
        view => "view",
        spans_to_jquery=> sub {
            my $self = shift;
            my $i = $h->{i} || 0;
            for my $s (@{$self->spans}) {
                $s->{top} *= 0.4;
                $s->{top} += $h->{tp} if $h->{tp};
                $s->{left} += $h->{lp} if $h->{lp};
                $s->{class} = "lyrics";
                my ($r, $g, $b) = map int rand 255, 1 .. 3;
               
                my $size = int rand 20;
                my $width = int rand 60;
                $s->{style} = "background: rgb($r, $g, $b); opacity:0.4; font-size: ${size}em; width: ${width}em";
            }
        }
     });
    push @texties, $text;
    return $self;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $height = $self->hostinfo->get("screen/height");
    $height ||= 900;
    my $h = {};


    $h->{tp} = $event->{y};
    $h->{lp} = $event->{x};
    $h->{x} = ($i * 30) + int rand $height;
    my @lyrics = map {$self->zlyrics} 1..3;
    $self->write($h, @lyrics);
}

1;
