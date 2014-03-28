package Lyrico;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'cd';
has 'app';
has 'lyrics';
has 'hostinfo';
my @texties;

my $i = 0;

sub new {
    my $self = bless {}, shift;
    my %p = @_;
    $self->app($p{app});
    $self->hostinfo($p{hostinfo});

    my $lyrics = capture("cat", "trampled_rose_lyrics");
    $self->lyrics([split "\n", $lyrics]);

    $self->write;

    $self->app->send("\$(window).on('click', clickhand);");
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
    my $h = shift;
    my $text = new Texty($self, [$self->zlyrics], undef, {
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
    my $event = shift;
    my $h = {};
    if ($event->{y} < 40) {
        my @js;
        for my $t (@texties) {
            my $id = $t->lines->[0]->{id};
            my $x = $t->lines->[0]->{left};
            if (int(rand 1)) {
                $x *= 0.3;
            }
            else {
                $x *= 2;
            }

            push @js, "\$('#$id').animate({left: $x}, 5000, 'swing');"
        }
        $self->app->send(join "\n", @js);

    } else {
        $h->{tp} = $event->{y};
        $h->{lp} = $event->{x};
        for my $i (1..10) {
            usleep 250;
            $h->{x} = ($i * 30) + int rand $self->hostinfo->get("screen/height");
            $self->write($h) for 1..7;
        }
    }
}

1;
