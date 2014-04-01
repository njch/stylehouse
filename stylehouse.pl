#!/usr/bin/perl
# copyright Steve Craig 2014
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Storable 'dclone';
use File::Slurp;
use Scriptalicious;
use Carp 'confess';
use v5.18;
say "\n\n\nwe are $0";

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

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use Hostinfo;
use Direction; 
use Texty;
use Dumpo;
use Lyrico;
use Codo;
use Menu;
use View;

get '/' => 'index';

my $hostinfo = new Hostinfo();
$hostinfo->set('0', $hostinfo);
$hostinfo->set('dumphooks', []);
helper 'hostinfo' => sub { $hostinfo };

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");
    $self->hostinfo->set("screen/tx", $self->tx);

    my $startup = sub {
#       Lyrico->new($self);
#        Direction->new("/home/s/Pictures", $self);
        Dumpo->new($self);
        Codo->new($self);
        Menu->new($self);
    };

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");
        Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

        # all sorts of things want to get in here...
        if ($msg eq "Hello!") {
            # clear the way, or merge with it?
            # need to blow away
        }
        elsif ($msg =~ /^screen: (\d+)x(\d+)$/) {
            $self->hostinfo->set("screen/width" => $1); # per client?
            $self->hostinfo->set("screen/height" => $2); # per client?
            # AND THEN...
            $startup->();
        }
        elsif ($msg =~ /^event (.+)$/s) {
            my $event = decode_json($1);
            
            if ($event->{type} eq "scroll") {
                my $ly = $self->hostinfo->get('Lyrico');
                $ly->event($event) if $ly;
            }
            $self->app->log->info("Looking up event handler");
            # find the Texty to ->event ->{ owner->event
            my $thing = $self->hostinfo->event_id_thing_lookup($event)
                unless $event->{type} eq "scroll";

            start_timer();
            unless ($thing) {
                $self->app->log->error("Thing lookup failed for $event->{id}");

                if (my $catcher = $self->hostinfo->get('eventcatcher')) {
                    $self->app->log->info("Event catcher found: $catcher");
                    $catcher->event($event);
                }
                else {
                    $self->send(
                        "\$('body').addStyle('dead').delay(250).removeStyle('dead');"
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
    });

    $self->hostinfo->send("ws.send('screen: '+screen.availWidth+'x'+screen.availHeight);");

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};

if (!caller) {
    my $daemon = Mojo::Server::Daemon->new(listen => ['http://*:3001']);
    $daemon->run();
}

app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>stylehouse</title>
    <script type="text/javascript" src="jquery-1.11.0.js"></script></head>
    <script>
      var ws;

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
            $('body').addClass('dead');
            console.log("WebSocket Error: " , e);
            reconnect();
          }
      }
      function reconnect () {
          console.log('waiting to retry');
          window.setTimeout(connect, 250);
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
            console.log(event);
            ws.send('event '+JSON.stringify(data))
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
        padding:1px;
    }
    .lyrics {
        position: absolute;
    }
    .on {
        color: white;
        background: #777;
    }
    </style>
    <body style="background: #ab6; font-family: monospace">
    <div id="menu" class="view" style="width:100%; background: #333; height: 20px;"></div>
    <div id="hodu" class="view" style="width:60%;  background: #352035; color: #afc; top: 50; height: 4000px"></div>
    <div id="view" class="view" style="width:40%; background: #c9f; height: 500px;"></div>
    <div id="hodi" class="view" style="width:40%; background: #09f; height: 5000px;"></div>
    </body>
</html>

