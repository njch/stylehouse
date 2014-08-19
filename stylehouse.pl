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

my $H = my $hostinfo = new Hostinfo();
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

        $H->{G}->w('on_message', {
            mojo => $self,
            msg => $msg,
            elvis => $elvis,
        });
        #$hostinfo->elvis_leaves($self);
    });

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $hostinfo->elvis_gone($self, $code, $reason);
      $self->app->log->debug("WebSocket closed with status $code: ".($reason||"no reason"));
    });

};


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

    %= include 'css'

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
        <link href="codemirror/theme/base16-dark.css" rel="stylesheet">
        <link rel="stylesheet" href="codemirror/addon/display/fullscreen.css">
        <script src="codemirror/addon/display/fullscreen.js"></script>
        <script src="codemirror/mode/perl/perl.js"></script>
    </head>
    <body id="body">
    </body>
</html>

@@ css.html.ep
        <style type="text/css">
div {
    opacity:0.9;
}
//#ground > div { opacity:0.2 }
#ground > div > div { opacity: 1; z-index:30; }
#flood:before {
    background: url(greencush.jpg);
    background-size: 100%;
    
    content: '';
    position: absolute;
   
    width: 100%;
    height: 100%;
    z-index: -1;
    opacity:0.5;
}
.insplatm {
    font-size: 15pt;
    text-shadow: 1px 1px 2px #fc0;
}
#Codo:before bollocks {
    background-image: url(blue-velvet-sofa.jpg);
    background-size: 100% 300%;
    
    content: '';
    position: absolute;
   
    width: 100%;
    height: 100%;
    z-index: -1;
    opacity:0.5;
}
div div {
    opacity:0.95;
}
div div div {
    opacity: 1;
}
.divlabel {
    z-index: -5;
}
.floated {
    position: fixed !important;
    top: 40%;
    right: 58%;
    padding: 3px;
}
#body {
    background: rgba(178,140,192,0.8);
    background-image:url('IMG_3524.JPG');
    background-size: 100%;
    font-family: monospace;
}
.splat-w {
    font-size:10pt;
    background-color:#445;
    max-height: 3em;
    word-wrap: break-word; overflow:hidden;
}
.inface {
    position:fixed !important;
    z-index:100 !important;
    top: 0.5em!important;
    right 0.5em!important;
}
.hidata:hover {
    color: white;
}
.NE {
    position: fixed;
    right: 0px;
    top: 0px;
}
span.en:hover{
    background-color: #fc6;
}
.data {
    position: absolute;
    white-space: pre;
    cursor: text;
}
.hear {
    font-family: serif;
    font-weight: 600;
    font-size: 22pt;
    color: white;
    opacity: 1;
}
.dead {
    background: #0d0e4d !important;
    opacity: 0.334;
}
.widdle {
    height: 1em !important;
    overflow: hidden !important;
}
.invis { display:none }
.widdle * {
    display: none;
}
#mess.widdle {
    height: 100% !important;
    width: 1em !important;
}
.widel {
    width: 50em !important;
}
.vvvv {
    position: relative;
    float: left;
}
.abspan > span {
    position: absolute;
}
.view {
    position: relative;
    float: left;
}
.view > span {
    position: absolute;
}
span.menu {
    position: relative !important;
    float: left;
    cursor: help;
}
.lyrics {
    position: absolute;
}
.on {
    color: white;
    background: #777;
}
.onn {
    color: black !important;
    text-shadow:2px 10px 7px #FF33CC !important;
}
div.CodeMirror-lines span {
    #font-family: u0400;
}
#Keys {
    font-size: 30pt;
}
.err { color: red; }
::-webkit-scrollbar {
    width: 20px;
}
#sky::-webkit-scrollbar {
    width: 40px;
}
#sky::-webkit-scrollbar-thumb {
    background: url(copper_anodes.jpg);
}
#Codo::-webkit-scrollbar {
    width: 40px;
}
#Codo::-webkit-scrollbar-thumb {
    background: url(copper_anodes.jpg);
    min-height:7em;
}
::-webkit-scrollbar-track {
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3); 
    -webkit-border-radius: 10px;
    border-radius: 29px;
}
 
/* Handle */
::-webkit-scrollbar-thumb {
    -webkit-border-radius: 10px;
    border-radius: 10px;
    background: url(greencush.jpg);
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.5); 
}
::-webkit-scrollbar-thumb:window-inactive {
    background: rgba(33,0,55,0.1); 
} 
        </style>

