#!/usr/bin/env perl
package S;
use lib 'l';
use lib 'll';
use Mojo::IOLoop;
use common::sense;

use H;
our $H;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
binmode(STDIN, ":utf8"); 
say '' for 1..9;


# MOVE post transport leveling
my $name = join(' ', @ARGV);
$name ||= 'S';
$H = H->new({name => $name, style => 'hut'});

if ($name eq 'O') {
    use Mojolicious::Lite;
    push @{app->static->paths}, '/home/s/styleshed/public';
    app->secrets([readlink '/home/s/stylehouse/msecret']);

    websocket '/s' => sub {
        my $mojo = shift;
        eval {
        $H->{G}->w(websocket => { M => $mojo });
        };
        G::sayre $@ if $@;
        $@ = '';
    };
    get '/' => sub{ 
       my $self = shift;
       $self->stash(ws_location => $self->url_for('s')->to_abs);
       $self->render(template=>'ws_page')
    };

    my $listen = $H->{listen_http};
    G::saybl("----------listeny $listen");
    app->start('daemon', '--listen' => "$listen");
}else{
      Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

__DATA__
@@ws_page.html.ep
<!DOCTYPE html>
<html><head>
  <style type="text/css">
      .NZ { display:none; };
      @font-face {
          font-family: DVSM;
          src: url('DejaVuSansMono.ttf');
      }
      @font-face {
          font-family: XMAS;
          src: url('MountainsofChristmas.ttf');
      }
      body {
          font-family: DVSM, mono;
      }
  </style>
  <link href="light.css" rel="stylesheet"></link>
  <script src="paper.js"></script>
  <script src="paper.animate.js"></script>
  <script canvas="display" type="text/paperscript">paper.uplg = new PaperAnimate.Updater();


      var shape = new Path.RegularPolygon(new Point(180, 170), 4, 100);
      shape.fillColor = '#e9e9ff';
      shape.selected = true;
      shape.animate(1, paper.uplg, true)
           .shear(0.1,0.2)
           .translate(new Point(200,100))
           .rotate(60)
           .scale(2);

      var dupe = new Path.RegularPolygon(new Point(180, 170), 4, 100);
      dupe.fillColor = '#3949ff';
      dupe.selected = true;
      dupe.shear(0.1,0.2);
      dupe.translate(new Point(700,100));
      dupe.rotate(60);
      dupe.scale(2);


   function onFrame(e) { paper.uplg.update(e); }
  </script>
<script src="jquery.min.js" type="text/javascript"></script>
</head><body style="margin: 0px; background: url('eye/Pic/ift/IMG_4021.JPG'); background: black; position:absolute; color: #0d2; overflow:hidden; height:100%; width:100%;">

    <div id='msgs' style="white-space: pre;position:absolute;font-size:60%;right:0em;bottom:0em;width:20%;height:20%; overflow:hidden;padding:0.2em;color:#abc;"> </div>

    <div id='ux' style="position:absolute;top:0em;
    right:0em;width:100%;height:100%; overflow:hidden;"> </div>

    <canvas id="display" resize></canvas>

    <script type="text/javascript">
      // default, top level #c
      var w = {conin: '<%= $ws_location %>'};
      var fail = 0;
      var a = {};
      var elvis = Math.random();
      var ws;
      var C = {};
      var conz = {};
      var ww = {};


      // splate

      a.e = function(e) {
          console.log("xut "+e);
          var m;
          try {
              m = eval(e);
          }
          catch (er) {
              console.log(["xutbang: ", e, er]);
              var ej = {er: {m: er.message, e: e}};
              s.reply(ej);
              a.m("!"+ ej.er.m);
          }
          m
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
          $('#msgs').prepend(e+"\n");
          //$('body').scrollTo('100%', 0);
      };


      // click, keys
      var ks; var oks;
      function clon () { $(window).on("click", a.cl); }
      function clof () { $(window).off("click", a.cl); }
      function keon () { $(window).on("keydown", a.ke); oks = ks; ks = s; }
      function keof () { $(window).off("keydown", a.ke); ks = oks; }
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
          if (ev.target.type == 'range') {
              d.rval = ev.target.value
          }
          d.name = tag.attr('name');
          //d.value = a.valblag(d.tag); // drapes
          while (tag && !tag.attr('id')) {
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
          if (d.which == 16 || d.which == 17 || d.which == 18) {
              return;
          }

          d.k = String.fromCharCode(ev.keyCode);

          if (!ws) {
              if (ks) {
                  ws = ks;
              }
              else {
                  ws = w;
              }
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
         if (C[conin] && C[conin].readyState == 1) {
                return;
         }
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
          $('body').stop().css('-webkit-filter', 'blur(3px) brightness(1.3) contrast(2)'); //# c dead # grayscale(0.8) hue-rotate(300deg) invert(0.8) saturate(4.3)
      };
      a.alive = function (c) {
          a.c("connected "+c.conin);
          if (c != w) {
              return;
          }
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
    </body></html>

