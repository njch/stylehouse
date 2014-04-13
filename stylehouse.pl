#!/usr/bin/perl
# copyright Steve Craig 2014
use strict;
use warnings;
use Scriptalicious;
die "no procserv" unless grep { /procserv.pl/ } `ps faux`;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Storable 'dclone';
use File::Slurp;
use Carp 'confess';
use v5.18;
use FindBin '$Bin';
say "\n\n\nwe are $Bin/$0";

=pod

hostinfo
for modules, IPs, files, everything
anything storage upgradable to sticky schemas

modules create a view div, fill it with spans
the spans' ids reach back to the module and/or controller it came from
passing it the whole element and "click" or whatever
lets eval everything from a WebSocket on the client

new screens/websockets attached to screen/tx

by the event dispatch... we see the waters edge
blowing up and coming back down in a linguatic clang
here to think about what to do

need to error check client side javascript

Texty, sending things through hostinfo awaits knowing about which screen its on
handled by whatever provisions the viewport

the modes that programs go through...
 - like awaiting event

dump hostinfo to a file (in another window)

going into the jungle horizontal
come out vertical again and pick up the dream

the tri is a point of balance

everything exists from two places

the unfolding along the texty line... jostling into space

yep line jostling
span spannering
space building
program cursor
tubes of where what & how

Devel::ebug interface
slurpy other programs

Codo is one whole universe of code
flip through them, prepare another program execution behind the one the user is looking at
so you can say, go here, what's this, watch this, find the pathway of its whole existence

put the view on a screen 

wow
t pus
Lyrico

we can sell Tolaga water to the Russians at $300 bucks a pop

keypress catcher:
$(document).keydown(function(e){
if (e.keyCode==90 && e.ctrlKey)
    $("body").append("<p>ctrl+z detected!</p>");
});

something like that

we want to give away the whole internet
but you have to become a member at $5/month
so we know who you are
the you can have it

facilitating human attachment

there's a greenhouse in London that cycles a whole day of mountain air underground and blows the cool night air over the plants during the day cos that's their environment

String::Koremutake
instead of urls


https://www.airbnb.co.nz/rooms/705210

tip, travel, the wake of

ebuge is supposed to run Devel::ebug and speak when it gets the chance via websocket
or maybe via http if that's not going to work...

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;
use lib 'lib';
use Mojolicious::Command::secret;

use Hostinfo;
use Direction; 
use Texty;
use Dumpo;
use Lyrico;
use Codo;
use Menu;
use View;
use Ebuge;
use Proc;
use Keys;
use Form;

get '/' => 'index';

clear_procserv_io();
my $hostinfo = new Hostinfo();
$hostinfo->set('0', $hostinfo);
$hostinfo->set('dumphooks', []);
$hostinfo->for_all([]);
helper 'hostinfo' => sub { $hostinfo };

my $stylehouse = bless {}, "God";
my $hands = {};

my $underworld = 1; # our fate's the most epic shift ever

# see what's there in all different ways
# get the language
# de-particulate
# roller coaster

# start git torrent
# do it all

# $0 has become a runtime
sub init {
    my $self = shift;

    Lyrico->new($hostinfo->intro);
    Dumpo->new($hostinfo->intro);

    $underworld = 0;
}

# where we pay attention
$hands = {
    geometry => [ sub {
        $hostinfo->send("ws.reply({geometry: {x: screen.availWidth, y: screen.availHeight}});");
    }, sub {
        my $sc = shift;
        $hostinfo->set("screen/width" => $sc->{x});
        $hostinfo->set("screen/height" => $sc->{y});
    } ],
    whatsthere => [ sub {
        $hostinfo->send("ws.reply({whatsthere: 'too hard'})");
    }, sub {
        $hostinfo->load_views(qw{menu hodu view hodi});
    } ],
};

sub menu_init {
    my $menu;
    if ($menu = $hostinfo->get("Menu")) {
        $menu->make_menu($hostinfo->tx_last);
        # TODO websocket server should hit the road and start one with the real stuff in it
        return;
    }

    Menu->new($hostinfo->intro);
    Keys->new($hostinfo->intro)->start;
}

my $handyin;
# the thing we can do all the time
sub reconnecty {
    my $self = shift;

    $self->hostinfo->tx($self->tx); # the way out! is the way in

    # find the old websocket and replace that
    $self->stash(
        tx => $self->tx,
    ); # swith sess (collect who => name (email) through Keys somehow)
    # we work on a git repository

    while (my ($name, $do) = each %$hands) {
        $do->[0]->();
        $handyin->{$name} = $do->[1];
    }

    Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);
}

sub handy_reconnections {
    my $self = shift;
    my $j = shift;
    
    while (my ($name, $do) = each %$handyin) {
        if ($j->{$name}) {
            $do->($j->{$name});
            delete $handyin->{$name};
        }
    }

    if (!keys %$handyin) {
        init() if $underworld;


        menu_init();
    }
}

# it's just about putting enough of it by itself so it makes sense
# urgh so simple
# when you stop trying the poetry builds itself into the language
# almost
# "I don't want to talk to you so you think"
# it's not to produce thinking, it's a recognition
# something more energetic

# hold lots of websockets

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");

    reconnecty($self);

    my $keys;
    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");
        $hostinfo->indi($self->tx);

        my $j;
        eval { $j = decode_json($msg); };
        return say "JSON DECODE FUCKUP: $@\n\nfor $msg\n\n\n\n" if $@;

        # handle startup responses until they're done
        if (keys %$handyin) {
            handy_reconnections($self, $j);
        }
        elsif (my $event = $j->{event}) {
            
            if ($event->{type} eq "scroll") {
                my $ly = $self->hostinfo->get('Lyrico');
                $ly->event($event) if $ly;
                return;
            }

            if ($event->{id} eq "Keys") {
                $keys->event($event);
                return;
            }

            $self->app->log->info("Looking up event handler");
            # find the Texty to ->event ->{ owner->event
            my $thing = $self->hostinfo->event_id_thing_lookup($event)
                unless $event->{type} eq "scroll";

            start_timer();
            unless ($thing) {
                $self->app->log->error("Thing lookup failed for $event->{id}");

                if (my $catcher = $self->hostinfo->get('clickcatcher')) {
                    $self->app->log->info("Event catcher found: $catcher");
                    $catcher->event($event);
                }
                else {
                    $self->send(
                        "\$('#body').addClass('dead').delay(250).removeClass('dead');"
                    );
                }
            }
            else {
                $self->app->log->info("Thing lookup $event->{id} -> $thing");
                $thing->event($event);
                # route to $1 via hostinfo register of texty thing owners
            }
            say "event handled in ".show_delta()."\n\n";
        }
        else {
            $self->send("// echo: $msg");
        }
        $hostinfo->indi(undef);
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};

sub clear_procserv_io {
    `cat /dev/null > proc/start`;
    `cat /dev/null > proc/list`;
}

if ($Bin =~ /test$/) {
    my $daemon = Mojo::Server::Daemon->new(app => app, listen => ['http://*:3001']);
    push @{app->static->paths}, "$Bin/../public";
    $daemon->run();
}

app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>stylehouse</title>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script></head>
    <script src="lib/codemirror.js"></script>
    <link rel="stylesheet" href="lib/codemirror.css">
    <script src="mode/javascript/javascript.js"></script>

    <script>
      var ws;
      WebSocket.prototype.reply = function reply (stuff) {
          ws.send(JSON.stringify(stuff));
      };

      function connect () {
          ws = new WebSocket('<%= url_for('stylehouse')->to_abs %>');
          ws.onmessage = function(event) {
            console.log(event.data);
            eval(event.data);
          };
          ws.onopen = function(e) {
             $(window).on('click', clickyhand);
             $('div span').fadeOut(100);
          }
          ws.onclose = function(e) {
             $(window).off('click', clickyhand);
            $('#body').addClass('dead');
            console.log("WebSocket Error: " , e);
            reconnect();
          }
      }
      function reconnect () {
          console.log('waiting to retry');
          window.setTimeout(connect, 256);
      }

      connect();

      function clickyhand (event) {
            var data = {
                id: event.target.id,
                value: event.target.innerText,
                type: event.type,
                shiftKey: event.shiftKey,
                ctrlKey: event.ctrlKey,
                altKey: event.altKey,
                x: event.clientX,
                y: event.clientY,
                pagex: window.pageXOffset,
                pagey: window.pageYOffset,
            };
            ws.reply({event: data});
            $('#Keys').focus;
        }
    </script>
    <style type="text/css">
    .data {
        position: absolute;
        white-space: pre;
    }
    .dead {
        background: black;
    }
    .view {
        position: relative;
        float: left;
    }
    .menu {
        padding: 5px;
        font-size: 20pt;
    }
    .lyrics {
        position: absolute;
    }
    .on {
        color: white;
        background: #777;
    }
    #Keys {
        font-size: 30pt;
    }
    </style>
    <body id="body" style="background: #ab6; font-family: monospace">
    </body>
</html>


