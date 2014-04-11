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

1;
