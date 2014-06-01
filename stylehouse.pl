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
use Codon;
use Git;
use View;
use Ebuge;
use Proc;
use Keys;
use Form;
use Travel;
use Ghost;
use Wormhole;
use Way;

my ($name) = $Bin =~ m{/(\w+)$};
say do { my $d = `pwd`; chomp $d; $d };
die "you ain't really here" unless $Bin ne `pwd`;
# here's our internet constellation
# N S E W
my $styleports = {
    stylehut => 5000,
    stylecoast => 4000,
    stylehouse => 3000,
    styleshed => 2000,
};
# vertical supports the two degrees of weather you can feed the web
# horizontal are your stable and unstable private research/life machines
# TODO nicely craft:
my $port = $styleports->{$name};
$port || die "COUGH COUGH COUGH please change the name of the directory the script is in to 'stylehouse'\n$Bin looks funny";
my $ip = "127.0.0.1";
$ip = "*" if $name eq "stylehut";
my $mojo_daemon_listen = "http://$ip:$port";

say "\n\n\nwe are $name";
my $x = `pwd`; chomp $x;
say "running from $x into $mojo_daemon_listen";

my $hostinfo = new Hostinfo();

$hostinfo->set('0', $hostinfo);
$hostinfo->set('Travel Travel', []);
$hostinfo->set('style', $name); # eventually to pick up a wormhole and etc.
$hostinfo->for_all([]);

# get rid of this with Base.pm
helper 'hostinfo' => sub { $hostinfo };

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

    $hostinfo->flood($hostinfo->data);

    #Lyrico->new($hostinfo->intro);
    Git->new($hostinfo->intro);
    Codo->new($hostinfo->intro);
    Keys->new($hostinfo->intro);

    $hostinfo->update_app_menu();
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
        $hostinfo->reload_views();
    } ],
    clickyhand => [ sub {
             $hostinfo->send("\$(window).on('click', clickyhand);");
    }, undef ],
    clear => [ sub {
             $hostinfo->send("\$('div span').fadeOut(100);");
    }, undef ],
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

my $first = 1;
get '/' => sub {
    my $self = shift;

    # TODO log this to find who can't make it to the websocket
    if ($first) {
        $first = 0;

        my $ws_location = $self->url_for('stylehouse')->to_abs;
        say "Updating stylehouse.js for websocket $ws_location";

        my $js = read_file("public/stylehouse.js");
        $js =~ s/(new\ WebSocket\(  )  .+?  (  \);)/$1'$ws_location'$2/sx; # invent an e pragma
        $js =~ m/( WebSocket.+\n)/;
        say "turned into $1";
        write_file("public/stylehouse.js", $js);
=pod
Prof Lue Calfman's quote from G
Prof Lue Calfman's quote from G
Prof Lue Calfman's quote from G
=cut
    }

    $self->render('index');
};

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

    # strangers are Elvis until they're not
    my $elvis = $hostinfo->elvis_connects($self);

    $self->stash(  tx => $self->tx);

    # setup setups
    my $handyin = {};
    while (my ($name, $do) = each %$hands) {
        my ($first, $last) = @$do;
        $first->();
        $handyin->{$name} = $do->[1] if $do->[1];
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


    $self->on(message => sub {
        my ($self, $msg) = @_;

        $hostinfo->elvis_enters($elvis, $self, $msg); # this'll all be way soon

        #return say "\n\nIGNORING Message: $msg\n\n\n\n" if $hostinfo->ignorable_mess($msg);
        
        my $j;
        if ($msg =~ /^{"event":{"id":"",/) {
            say "STUPID MESSAGE: $msg";
        }
        eval { $j = decode_json($msg); };
        return say "JSON DECODE FUCKUP: $@\n\nfor $msg\n\n\n\n" if $@;


        # all this stuff before they join the stream
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
        if ($j->{claw} && $hostinfo->claw($j)) {
            # done
        }
        elsif (my $k = $j->{k}) {
            my $keys = $hostinfo->getapp("Keys");
            return unless $keys;
            $keys->key($k);
        }
        elsif (my $s = $j->{s}) {
            # the viewport of the browser moves..
#Lyrico used to do stuff here, it's a bit crazy but it's got potential...
# for a bit cloud of colourful chatter that builds up in layers and moves off to new lands etc.
# then bringing things back together is the key.... substance... legible shrines to anythings...
            my $lye = $hostinfo->getapp("Lyrico");
            return unless $lye;
            $lye->scroll($s);
        }
        elsif (my $event = $j->{event}) {
            $self->app->log->info("Looking up event handler");
            my $id = $event->{id};

            my $thing = $hostinfo->tv_by_id($event->{id}) if $id;

            start_timer();

            if ($thing) {
                $thing->event($event);
            }
            else {
                $id ?
                    $self->app->log->error("Thing lookup failed for $id")
                  : $self->app->log->error("Thing lookup failed, lacking id");

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
            say "event handled in ".show_delta()."\n\n";
        }
        else {
            $self->send("// echo: $msg");
        }
        #$hostinfo->elvis_leaves($self);
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $hostinfo->elvis_gone($self, $code, $reason);
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};

my $daemon = Mojo::Server::Daemon->new(app => app, listen => [$mojo_daemon_listen]);
$daemon->run();

__DATA__

@@ index.html.ep
<!doctype html><html>
    <head>
        <title>stylehouse</title>

        <link  href="stylehouse.css" rel="stylesheet">

        <script src="jquery-1.11.1.min.js"></script>
        <script src="stylehouse.js"></script>
        <script src="tabby.js"></script>
        <script src="jquery.scrollTo.js"></script>

    </head>
    <body id="body">
    </body>
</html>
