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
use Carp 'confess', 'verbose';
use v5.18;
use FindBin '$Bin';
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
binmode(STDIN, ":utf8");

use Mojolicious::Lite;
use lib 'lib';
use Hostinfo;
use Texty;
use Lyrico;
use Codo;
use Codon;
use Git;
use View;
use Proc;
use Keys;
use Travel;
use Ghost;
use Wormhole;
use Way;

my ($name) = $Bin =~ m{/(\w+)$};
my $title = $name;
my ($pwd) = `pwd`; chomp $pwd;
die "ain't really here" unless $Bin eq $pwd;
my $style = $name;
($title = $style) =~ s/(.)/$1\N{U+0489}/g;

my $listen = readlink('listeno') || readlink('listen') || "127.0.0.1:3000";
$listen = "http://$listen" unless $listen =~ /^\w+:\//;

$listen = [ split /, ?/, $listen ];
say "! enlistening $name $$ @$listen\n\n\n\n\n\n\n\n\n\n

";
my $H = my $hostinfo = new Hostinfo();
helper 'hostinfo' => sub { $hostinfo };
$H->set('style', $name); # eventually to pick up a wormhole and etc.
$H->set('sstyle', $style); # eventually to pick up a wormhole and etc
get '/' => sub {
    my $self = shift;

    # TODO log this to find who can't make it to the websocket
    $self->stash(ws_location => $self->url_for('stylehouse')->to_abs);
    
    $self->stash(title => $title);
    $self->render('index');
};
websocket '/stylehouse' => sub {
    my $self = shift;
    $hostinfo->{G}->w(websocket => { M => $self });
};
my $daemon = Mojo::Server::Daemon->new(app => app, listen => $listen);
$daemon->run();
sub love {
    
}

__DATA__

@@ index.html.ep
<!doctype html><html>
    <head>
        <title><%= $title || "stylehouse" %></title>

    %= include 'thecss'
    %= include 'jquery'
    <link rel="stylesheet" type="text/css" href="light.css">
    %= include 'thejs'
    %= include 'codemirror'


    </head>
    <body id="body">
    </body>
</html>

@@ jquery.html.ep
        <script src="jquery-1.10.2.js"></script>
        <script src="jquery-ui-1.10.4.min.js"></script>
        <script src="jquery.scrollTo.js"></script>
        <script src="jquery.color.js"></script>
        
        <script src="jquery.transform2d.js"></script>
        <script src="jquery.hoverIntent.js"></script>
@@ codemirror.html.ep
        <script src="codemirror/lib/codemirror.js"></script>
        <link href="codemirror/lib/codemirror.css" rel="stylesheet">
        <link href="codemirror/theme/night.css" rel="stylesheet">
        <link href="codemirror/theme/midnight.css" rel="stylesheet">
        <link href="codemirror/theme/base16-dark.css" rel="stylesheet">
        <link rel="stylesheet" href="codemirror/addon/display/fullscreen.css">
        <script src="codemirror/addon/display/fullscreen.js"></script>
        <script src="codemirror/mode/perl/perl.js"></script>

@@ thecss.html.ep
        <style type="text/css">
div {
    opacity:0.9;
}
//#ground > div { opacity:0.2 }
#ground > div > div { opacity: 1; z-index:30; }
#flood:before {
    background: url(i/greencush.jpg);
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
    background-image: url(i/blue-velvet-sofa.jpg);
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
    background-image:url('i/IMG_3524.JPG');
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
    -webkit-filter: blur(4px) brightness(2.8) contrast(4.9) grayscale(0.8) hue-rotate(300deg) invert(0.8) saturate(4.3);

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
    -webkit-filter: brightness(1.4) contrast(10) grayscale(0.2) hue-rotate(140deg) invert(0.3) saturate(8.5);
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
    background: url(i/copper_anodes.jpg);
}
#Codo::-webkit-scrollbar {
    width: 40px;
}
#Codo::-webkit-scrollbar-thumb {
    background: url(i/copper_anodes.jpg);
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
    background: url(i/greencush.jpg);
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.5); 
}
::-webkit-scrollbar-thumb:window-inactive {
    background: rgba(33,0,55,0.1); 
} 
        </style>
@@ thejs.html.ep
<script type="text/javascript">
var ws;
var fail = 0;
var db = 0;
var A;
function connect () {
  ws = new WebSocket('<%= $ws_location %>');
  ws.onmessage = function(event) {
  
        console.log(event.data);
    try {
        eval(event.data);
    } catch (e) {
        ws.reply({e:e.message, d:event.data});
    }
  };
  ws.onopen = function(e) {
    fail = 0;
    $('#body').removeClass('dead');
  };
  ws.onclose = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    reconnect();
  };
  ws.onerror = function(e) {
     $(window).off('click', clickyhand);
    $('#body').addClass('dead');
    console.log("WebSocket Error: " , e);
    //reconnect();
  };
}
function reconnect () {
  fail++;
  console.log('waiting to retry');
  if (fail < 20000) {
      window.setTimeout(connect, 256);
  }
  else {
      window.setTimeout(connect, 25600);
  }
}
WebSocket.prototype.reply = function reply (stuff) {

  console.log(stuff);

  this.send(JSON.stringify(stuff));
};

function clickon () { $(window).on("click", clickyhand); }
function clickoff () { $(window).off("click", clickyhand); }
function clickyhand (event) {
    var tag = $(event.target);
    
    var value = ''+tag.contents();
    while (!(tag.attr('id') || tag.attr('class'))) {
        tag = tag.parent();
    }
    if (value && value.length >= 640) {
        value = '';
    }
    var data = {
        id: tag.attr('id'),
        class: tag.attr('class'),
        value: value,
        type: event.type,
        S: 0+event.shiftKey,
        C: 0+event.ctrlKey,
        A: 0+event.altKey,
        M: 0+event.metaKey,
        x: event.clientX,
        y: event.clientY,
        pagex: window.pageXOffset,
        pagey: window.pageYOffset,
    };
    var W = tag.closest( "wormhole" ).attr('id');
    if (W) {
        data.W = W;
    }
    var ux = tag.closest( "ux" ).attr('id');
    if (ux) {
        data.ux = ux;
    }
    ws.reply({event: data});
}
var nohands = 0;
var handelay = 10;
function keyhand (e) {
    if (nohands) {
        return;
    }
    setTimeout(function () {
        nohands = 0;
    }, handelay);
    nohands = 1;
    var data = {
        type: e.type,
        S: 0+e.shiftKey,
        C: 0+e.ctrlKey,
        A: 0+e.altKey,
        M: 0+e.metaKey,
        which: e.which,
        k: String.fromCharCode(e.keyCode),
    };
    ws.reply({event: data});
}
connect();
</script>

