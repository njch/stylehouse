#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Scriptalicious;
use YAML::Syck;
use JSON;
use List::MoreUtils qw"uniq";
use Storable 'dclone';
use File::Slurp;
use Carp 'confess';
use v5.18;
use FindBin '$Bin';
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
binmode(STDIN, ":utf8");

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
# style {

my ($name) = $Bin =~ m{/(\w+)$};
my $title = $name;
my ($pwd) = `pwd` =~ /(.+)\n/;
die "ain't really here" unless $Bin eq $pwd;

my ($style) = $name =~ /style(\w+)$/;
$style ||= $name;
($title = $style) =~ s/(.)/$1\N{U+0489}/g;

# here's our internet constellation
# N S E W
my $stylelist =
{
    hut   => ['*', 5000],
    coast => [undef, 4000],
    house => [undef, 3000],
    shed  => [undef, 2000],
    bucky => [undef, 1000],
};
# vertical supports the two degrees of weather you can feed the web
# horizontal are your stable and unstable private research/life machines

my $listen = readlink('listen');

my $port = $1 if $listen && $listen =~ /:(\d+)$/;
my $addr = $1 if $listen && $listen =~ /^(?:http:\/\/)?(.+)(?::\d+)?\/?$/;

my $listen_formed = $port && $addr;
my $sr = $stylelist->{$style};
if (!$port || !$addr) {
    $port ||= $sr->[1] if $sr;
    $port ||= "2000";
    $addr ||= $sr->[0] if $sr;
    $addr ||= "127.0.0.1";
}

$listen = "http://$addr:$port" unless $listen_formed;
$listen = [ split /, ?/, $listen ];
# this R doesn't scale its default settings, shrug

say "! enlistening $name $$ @$listen












";

my $hostinfo = new Hostinfo();
$hostinfo->set('style', $name); # eventually to pick up a wormhole and etc.
$hostinfo->set('sstyle', $style); # eventually to pick up a wormhole and etc.
$hostinfo->set('stylelist', $stylelist);
$hostinfo->{underworld} = 1; # our fate's the most epic shift ever
# SED name is styleblah, $style as far above is blah. layers peel everywhere.

# get rid of this with Base.pm... or something
helper 'hostinfo' => sub { $hostinfo };

my $hands = {};


# see what's there in all different ways
# get the language
# de-particulate
# roller coaster

# start git torrent
# do it all

# $0 has become a runtime
$hands = {
    geometry => [ sub {
        $hostinfo->send("ws.reply({geometry: {x: screen.availWidth, y: screen.availHeight}});");
    }, sub {
        $hostinfo->screen_height(shift);
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

# hold lots of websocket

my $first = 1;
get '/' => sub {
    my $self = shift;

    # TODO log this to find who can't make it to the websocket
    if ($first) {
        $first = 0;

        my $ws_location = $self->url_for('stylehouse')->to_abs;
        say "Updating stylehouse.js for websocket $ws_location";

        my $js = read_file("stylehouse.js");
        $js =~ s/(new\ WebSocket\(  )  .+?  (  \);)/$1'$ws_location'$2/sx; # invent an e pragma
        $js =~ m/( WebSocket.+\n)/;
        say "turned into $1";
        unlink "public/stylehouse.js";
        write_file("public/stylehouse.js", $js);
    }
    
    $self->stash(title => $title);
    $self->render('index');
};
websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300000);

    # strangers are Elvis until they're not
    my $elvis = $hostinfo->elvis_connects($self);

    $self->stash(  tx => $self->tx);

    $hostinfo->snooze(30000);

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
        
        return say "\n\nIGNORING Message: $msg\n\n\n\n"
            if $hostinfo->ignorable_mess($msg);
        
        
        my $j;
        eval { $j = $hostinfo->decode_message($msg); };
        if ($@) {
            $hostinfo->error("message decode fup", $@);
            return;
        }
        
        
        
        
        # all this stuff before they join the stream
        my $done = 0;
        if ($self->stash('handy')) {
            $self->stash('handy')->($self, $j);
            say "Handi";
            return if $self->stash('handy');
            $done = 1;
        }


        # it beings! not that we don't come through here all the time
        $hostinfo->{G}->w('elvinit') if $hostinfo->{underworld};
        
        eval { dostuff($self, $j, $msg); };
        if ($@) {
            $hostinfo->error("message process fup", $@);
            return;
        }
        #$hostinfo->elvis_leaves($self);
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $hostinfo->elvis_gone($self, $code, $reason);
      $self->app->log->debug("WebSocket closed with status $code: ".($reason||"no reason"));
    });

};
sub dostuff {
    my ($self, $j, $msg) = @_;
    # ongoing stuff
    if ($j->{claw} && $hostinfo->claw($j)) {
        # done
    }
    elsif (my $k = $j->{k}) {
        my $keys = $hostinfo->getapp("Keys");
        $keys->key($k) if $keys;
    }
    elsif ($j->{e}) {
        die $j->{d} if $hostinfo->{JErrors}++ > 3;
        $hostinfo->error("javascript error from client", $j->{d}, $j->{e});
    }
    elsif (my $s = $j->{s}) {
        # the viewport of the browser moves..
        #Lyrico used to do stuff here, it's a bit crazy but it's got potential...
        # for a bit cloud of colourful chatter that builds up in layers and moves off to new lands etc.
        # then bringing things back together is the key.... substance... legible shrines to anythings...
        my $lye = $hostinfo->getapp("Lyrico");
        $lye->scroll($s) if $lye;
    }
    elsif (my $event = $j->{event}) {
        $self->app->log->info("Looking up event handler");
        my $id = $event->{id};

        if ($id =~ /^hi_|procstartwatch/) {
            $hostinfo->send("\$('#$id').toggleClass('widdle');");
        }
        elsif ($id =~ /_out$/) {
            $hostinfo->send("\$('#$id').toggleClass('widel');");
        }

        my $thing = $hostinfo->tv_by_id($event->{id}) if $id;

        start_timer();

        if ($thing) {
            $self->app->log->info("TV  $thing->{id}");
            $thing->event($event);
        }
        else {
            my $s = "TV not found".( $id ? ": $id" : ", lacking id");
            $self->app->log->info("$s");

            if (my $catcher = $self->hostinfo->get('clickcatcher')) {
                $self->app->log->info("Event catcher found: $catcher");
                $catcher->event($event);
            }
            else {
                $self->app->log->info("NOTHING");
                $self->send(
                    "\$('#body').addClass('dead').delay(250).removeClass('dead');"
                );
            }
        }
        say "event handled in ".show_delta()."\n\n";
    }
    else {
        my $undorf = !defined $msg ? " is~undef~" : "";
        $hostinfo->error("EH!? '$msg'$undorf");
    }
    say "Done\n\n\n\n\n";
}

say " Listen @$listen!?";
my $daemon = Mojo::Server::Daemon->new(app => app, listen => $listen);
$daemon->run();
sub love {
    
}

__DATA__

@@ index.html.ep
<!doctype html><html>
    <head>
        <title><%= $title || "stylehouse" %></title>

        <link  href="stylehouse.css" rel="stylesheet">

        <script src="jquery-1.10.2.js"></script>
        <script src="jquery-ui-1.10.4.min.js"></script>
        <script src="stylehouse.js"></script>
        <script src="tabby.js"></script>
        <script src="jquery.scrollTo.js"></script>
        <script src="jquery.color.js"></script>
        
        <script src="jquery.transform2d.js"></script>
        <script src="jquery.hoverIntent.js"></script>

        <script src="codemirror/lib/codemirror.js"></script>
        <link href="codemirror/lib/codemirror.css" rel="stylesheet">
        <link href="codemirror/theme/night.css" rel="stylesheet">
        <link href="codemirror/theme/midnight.css" rel="stylesheet">
        <link rel="stylesheet" href="codemirror/addon/display/fullscreen.css">
        <script src="codemirror/addon/display/fullscreen.js"></script>
        <script src="codemirror/mode/perl/perl.js"></script>
    </head>
    <body id="body">
    </body>
</html>

