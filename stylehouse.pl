#!/usr/bin/perl
use strict;
use warnings;
use Scriptalicious;
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


facilitating human attachment

there's a greenhouse in London that cycles a whole day of mountain air underground and blows the cool night air over the plants during the day cos that's their environment

String::Koremutake
instead of urls

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;
use lib 'lib';
use Hostinfo;
use Direction; 
use Texty;
use Lyrico;
use Codo;
use Menu;
use View;
use Ebuge;
use Proc;
use Keys;
use Form;
use Travel;
use Ghost;
use Wormhole;
use Way;

die "no procserv" unless grep /procserv.pl/, `ps faux`;

for my $m (grep /use lib 'lib';/.../^\n$/, read_file($0)) {
    say $m;
    $m =~ /use (\w+);/ || next;
    #run("perl -Ilib -c lib/$1.pm");
}

get '/' => 'index';

clear_procserv_io();
my $hostinfo = new Hostinfo();
$hostinfo->set('0', $hostinfo);
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
    #Codo->new($hostinfo->intro);

    $hostinfo->make_floodzone();
    $hostinfo->make_app_menu();
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
        $hostinfo->send("ws.reply({whatsthere: 'too hard'}); \$('body div').remove();");
    }, sub {
        $hostinfo->load_views(qw{menu hodu view hodi});
    } ],
};

my $handyin;

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
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

    # collect everyone
    # TODO should be per screen (people + div collection)
    # also means per websocket bump individual
    $hostinfo->new_god($self->tx);

    # here's our individual
    $self->stash(  tx => $self->tx);

    # setup setups
    my $handyin = {};
    while (my ($name, $do) = each %$hands) {
        my ($first, $last) = @$do;
        $first->();
        $handyin->{$name} = $do->[1];
    }
    $self->stash(  handy => sub {
        my $self = shift; # mojo, should be person or so
        my $j = shift;

        while (my ($name, $do) = each %$handyin) {
            if ($j->{$name}) {
                $do->($j->{$name});
                delete $handyin->{$name};
            }
        }
        unless (%$handyin) {
            $self->stash(handy => undef);
        }
    });
    # swith sess (collect who => name (email) through Keys somehow)
    # we work on a git repository






    my $keys;
    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");
        $hostinfo->god_enters($self->tx);

        my $j;
        if ($msg =~ /^{"event":{"id":"",/) {
            return say "STUPID MESSAGE: $msg";
        }
        eval { $j = decode_json($msg); };
        return say "JSON DECODE FUCKUP: $@\n\nfor $msg\n\n\n\n" if $@;

        # handle startup responses until they're done
        my $done = 0;
        if ($self->stash('handy')) {
            $self->stash('handy')->($self, $j);
            say "Handi";
            return if $self->stash('handy');
            $done = 1;
        }



        # it beings! not that we don't come through here all the time
        init() if $underworld;


        # ongoing stuff
        if (my $event = $j->{event}) {
            
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
            my $thing = $self->hostinfo->event_id_thing_lookup($event->{id})
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
                $self->hostinfo->error("Thing dispatch" => $thing);
                $thing->event($event);
                # route to $1 via hostinfo register of texty thing owners
            }
            say "event handled in ".show_delta()."\n\n";
        }
        else {
            $self->send("// echo: $msg");
        }
        $hostinfo->god_leaves();
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      my $tx = $self->tx;
      $hostinfo->god_leaves($tx, $code, $reason);
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
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="lib/codemirror.js"></script>
    <link rel="stylesheet" href="lib/codemirror.css">
    <script src="mode/perl/perl.js"></script></head>

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
    .view {
        position: relative;
        float: left;
    }
    .view span {
        position: absolute;
    }
    .menu {
        padding: 5px;
        font-size: 20pt;
    }
    .view .menu {
        font-size: 8pt;
    }
    .lyrics {
        position: absolute;
    }
    .codocode {
        white-space:pre;
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


