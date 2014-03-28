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
find the screen for the event and pass that to the event handler!

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use Hostinfo;
use Direction; 
use Texty;
use Dumpo;
use Lyrico;

get '/' => 'index';

my $hostinfo = new Hostinfo();
helper 'hostinfo' => sub { $hostinfo };

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");
    $self->hostinfo->set("screen/tx", $self->tx);

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
        }
        elsif ($msg =~ /^event (.+)$/s) {
            my $event = decode_json($1);
            
            my $catcher = $self->hostinfo->get('eventcatcher');
            if (defined $catcher) {
                $catcher->event($self->tx, $event);
            }
            else {
                $self->app->log->error("Thing lookup for $event->{id}");
                my $thing = $self->app->hostinfo->event_id_thing_lookup($event);
                
                unless ($thing) {
                    $self->app->log->error("Thing lookup failed for $event->{id}");
                    $self->send(
                        "\$(body).addStyle('dead').delay(250).removeStyle('dead');"
                    );
                }
                else {
                    $self->app->log->info("Thing lookup $event->{id} -> $thing->{thing}");
                    $thing->{thing}->event($event);
                    # route to $1 via hostinfo register of texty thing owners
                }
            }
        }
        else {
            $self->send("// echo: $msg");
        }
    });

    # this bit could be like a transaction, handler hooked into message
    $self->send("ws.send('screen: '+screen.availWidth+'x'+screen.availHeight.')");
    # startup applications:
    $self->app->log->debug("Is; ".$self->app);
    Lyrico->new($self);
#    push @apps, Direction->new("/home/s/Music", $self->app);
#    push @apps, Dumpo->new();

    # connect above dispatcher to conty
    # ask for screen width, etc from client

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};


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
         
          ws.onclose = function() {
            $('body').addClass('dead');
          }
      }
      function reconnect () {
          console.log('waiting to retry');
          window.setTimeout(connect, 250);
      }

      connect();

      function clickhand (event) {
            var data = {
                id: event.target.id,
                type: event.type,
                shiftKey: event.shiftKey,
                ctrlKey: event.ctrlKey,
                altKey: event.altKey,
                x: event.clientX,
                y: event.clientY,
            };
            console.log(event);
            ws.send('event '+JSON.stringify(data))
      }
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
    #hodu.data {
        position: relative;
    }
    .lyrics {
        width: 80px;
        position: absolute;
    }
    </style>
    <body style="background: #ab6; font-family: monospace">
    <div id="view" class="view" style="float:left; width:40%; background: #c9f; height: 500px;"></div>
    <div id="hodu" class="view" style="float:left; width:58%; border: 1px solid black; background: #ce9; top: 50; height: 4000px"></div>
    </body>
</html>

