#!/usr/bin/env perl
package S;
use Mojolicious::Lite;
use common::sense;

use lib 'l';
use H;
our $H;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
binmode(STDIN, ":utf8"); 
say '' for 1..9;

get '/' => sub{ 
   my $self = shift;
   $self->stash(ws_location => $self->url_for('s')->to_abs);
   $self->render(template=>'ws_page')
};

# MOVE post transport leveling
my $name = join(' ', @ARGV);
$name ||= 'S';
$H = H->new({name => $name, style => 'stylehut'});

websocket '/s' => sub {
    my $mojo = shift;
    $H->enwebsocket($mojo);
};
push @{app->static->paths}, '/home/s/styleshed/public';
app->secrets([readlink '/home/s/stylehouse/msecret']);

my $listen = $H->{listen_http};
say "\n\n        listen to $listen\n";
app->start('daemon', '--listen' => "$listen");

__DATA__
@@ws_page.html.ep
<!DOCTYPE html>
<html><head>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js" type="text/javascript"></script>
  <script src="//h:3000/jquery.scrollTo.js"></script>
</head><body style="background: url('i/greencush.jpg'); background: black; position:absolute; color: #0f2; overflow:hidden; height:100%; width:100%;">

    <div id='msgs' style="white-space: pre;position:absolute;left:0em;bottom:0em;width:44%;min-height:100%; overflow:hidden;padding:0.2em;"> </div>
    <div id='ux' style="position:absolute;right:0em;width:96%;height:100%; overflow:hidden;"> </div>

    <script type="text/javascript">
      // default, top level #c
      var w = {conin: '<%= $ws_location %>'};
      var fail = 0;
      var a = {};
      var ws;
      var C = {};
      var conz = {};


      // splate

      a.e = function(e) {
          console.log("xut "+e);
          try {
              eval(e);
          }
          catch (er) {
              var ej = {er: {m: er.message, e: e}};
              s.reply(ej);
              a.m("!"+ ej.er.m);
          }
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


      // click, keys

      function clon () { $(window).on("click", a.cl); }
      function clof () { $(window).off("click", a.cl); }
      function keon () { $(window).on("keydown", a.ke); }
      function keof () { $(window).off("keydown", a.ke); }
      var keyjam = 0;
      var keyjamfor = 10;
      a.cl = function(ev, ws) {
          if (keyjam) {
              return;
          }
          setTimeout(function () { keyjam = 0; }, keyjamfor);
          keyjam = 1;

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
              var conin = conz[W];
              if (conin) {
                  ws = C[conin];
              }
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
      a.dscam = function(d,ev) {
          d.type = ev.type;
          d.S = 0+ev.shiftKey;
          d.C = 0+ev.ctrlKey;
          d.A = 0+ev.altKey;
          d.M = 0+ev.metaKey;
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
             s = c;
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
          $('body').stop().css('-webkit-filter', 'blur(4px) brightness(2.8) contrast(4.9) grayscale(0.8) hue-rotate(300deg) invert(0.8) saturate(4.3)');
      };
      a.alive = function (c) {
          if (c != w) {
              return;
          }
          a.c("connected "+c.conin);
          $('body').stop().css('-webkit-filter', '');
      };
      a.recon = function (c) {
        fail++;
        var t = 25600;
        if (fail < 20000) {
            t = 256;
        }
        window.setTimeout(function(){
            if (C[c.conin] == c) { // still
                a.con(c);
            }
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
      //#c

    </body></html>

