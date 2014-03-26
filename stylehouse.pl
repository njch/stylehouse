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

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use Hostinfo;
use Direction; 
use Texty;

get '/' => 'index';
my $haps;
my $hostinfo = Hostinfo->new();
helper 'hostinfo' => sub { $hostinfo };

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");
        Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

    say "Message and hostinfo is:";
    $hostinfo->dump();
        # all sorts of things want to get in here...
        if ($msg eq "Hello!") {
            # clear the way, or merge with it?
            # need to blow away
            Direction->new(cd => "/home/s/Music", app => $self);
        }
        elsif ($msg =~ /^Width: (\d+)px$/) {
            $self->hostinfo->set("screen/width" => $1); # per client?
        }
        elsif ($msg =~ /^event (.+)$/s) {
            my $event = decode_json($1);
            $self->hostinfo->dispatch_event($event);
            # route to $1 via hostinfo register of texty thing owners
        }
        else {
            $self->send("// echo: $msg");
        }
    });

    $self->send("ws.send('Width: '+\$('#view').width()+'px')");
    # connect above dispatcher to controllery
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
          
          ws.onopen = function() {
            $('body').removeClass('dead');
            ws.send('Hello!');
          }

          ws.onclose = function() {
            $('body').addClass('dead');
            //reconnect();
          }
      }
      function reconnect () {
          console.log('waiting to retry');
          window.setTimeout(connect, 250);
      }

      connect();


    </script>
    <style type="text/css">
    .data {
        position: absolute;
        white-space: pre;
    }
    .dead {
        background: black;
    }
    </style>
    <body style="background: #ab6; font-family: monospace">
    <div id="view" class="view" style="position: relative; background: #ce9; height: 400px;"></div>
    </body>
</html>

