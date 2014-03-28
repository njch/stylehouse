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

new screen created in Hostinfo
which fires a screen attachment conty

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use Hostinfo;
use Direction; 
use Texty;
use Dumpo;
use Lyrico;
use Conty;

get '/' => 'index';

helper 'hostinfo' => sub { Hostinfo->new() };
helper 'conty' => sub { Conty->new() };

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");
        Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

        $self->conty->message($self, $msg);
    });

    $self->app->log->info("happens:!". anydump($self->app->conty));
    $self->conty->initiate();
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

