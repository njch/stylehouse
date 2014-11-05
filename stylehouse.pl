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
my $H = my $hostinfo = new Hostinfo({name => $name, style => $style});
helper 'hostinfo' => sub { $hostinfo };
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
        <link href="codemirror/addon/display/fullscreen.css" rel="stylesheet">
        <script src="codemirror/addon/display/fullscreen.js"></script>
        <script src="codemirror/mode/perl/perl.js"></script>

@@ thecss.html.ep
        <style type="text/css">
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
    overflow: hidden;
    margin: 0px;
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
  // default, top level #c
  var w = {conin: '<%= $ws_location %>'};
  var fail = 0;
  var a = {};
  var C = {};

  // splat #c
  a.e = function(e) {
      console.log("xut "+e);
      eval(e);
  };
  a.m = function(e) {
      var d = e.substr(0,1);
      if (d == " ") {
        a.e(e);
      }
      else {
        if (d == ".") {
          e = '<span style="font-size:66%">'+e+'</span>';
        }
        a.c(e);
      }
  };
  a.c = function(e) {
      $('#msgs').append(e+"\n");
      //$('body').scrollTo('100%', 0);
  };
  // click, keys #c
  function clon () { $(window).on("click", a.cl); }
  function clof () { $(window).off("click", a.cl); }
  function keon () { $(window).on("keydown", a.ke); }
  function keof () { $(window).off("keydown", a.ke); }
  a.cl = function(ev, ws) {
      var d = {};
      a.dscam(d,ev);
      
      
      var tag = $(ev.target);
      //d.value = a.valblag(d.tag); // drapes
      while (!(tag.attr('id') || tag.attr('class'))) {
          tag = tag.parent();
      }
      d.id = tag.attr('id');
      d.class = tag.attr('class');
      d.x = ev.clientX;
      d.y = ev.clientY;
      d.pagex = window.pageXOffset;
      d.pagey = window.pageYOffset;
      var W = tag.closest( "ww" ).attr('id');
      if (W) {
          d.W = W;
      }
      var ux = tag.closest( "ux" ).attr('id');
      if (ux) {
          d.ux = ux;
      }

      if (!ws) {
          ws = w;
      }
      ws.reply({event: d});
  };
  a.dscam = function(d,ev) {
      d.type = ev.type;
      d.S = 0+ev.shiftKey;
      d.C = 0+ev.ctrlKey;
      d.A = 0+ev.altKey;
      d.M = 0+ev.metaKey;
  };
  var keyjam = 0;
  var keyjamfor = 10;
  a.ke = function(ev, ws) {
      if (keyjam) {
          return;
      }
      setTimeout(function () { keyjam = 0; }, keyjamfor);
      keyjam = 1;

      var d = {};
      a.dscam(d,ev);
      d.which = ev.which;
      d.k = String.fromCharCode(ev.keyCode);

      if (!ws) {
          ws = w;
      }
      ws.reply({event: d});
  };
  a.valblag = function(tag) {
      var value = ''+tag.contents();
      if (value && value.length >= 640) {
          value = '';
      }
      value;
  };
  // websockety #c
  a.con = function(c) {
     var conin = c.conin;
     c = new WebSocket(conin);
     c.conin = conin;

     C[conin] = c;
     if (w.conin === conin) {
             w = c;
     }

     c.onmessage = function (ev) {
         a.m(ev.data);
     };
     c.onopen = function () {
        a.alive(c);
     };
     c.onclose = function () {
        a.dead(c);
        a.recon(c);
     };
  };
  a.dead = function (c) {
      if (c != w) {
          return;
      }
      a.c("closed "+c.conin);
      $('body').stop().animate({opacity: 0.6}, 200);
  };
  a.alive = function (c) {
      if (c != w) {
          return;
      }
      a.c("connected "+c.conin);
      $('body').stop().animate({opacity: 1}, 200);
  };
  a.recon = function (c) {
    fail++;
    var t = 25600;
    if (fail < 20000) {
        t = 256;
    }
    window.setTimeout(function(){
        a.con(c);
    }, t);
  }
  WebSocket.prototype.reply = function reply (stuff) {
        this.send(JSON.stringify(stuff));
  };
  WebSocket.prototype.r = function r (stuff) {
        this.send(JSON.stringify(stuff));
  };

  $(document).ready(function(){
      a.c("ello");
      a.con(w);
  });
</script>

