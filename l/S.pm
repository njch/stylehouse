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

my $listen = readlink('listen');
    my ($host,$port, $wa) = split ':', $listen;
    die "too much listen" if $wa;
    ($port, $host) = (2000, undef) if !$port && $host =~ /^\d+$/;
    $port ||= 2000;
    $host ||= '127.0.0.1';
    $port += 1; # TODO
$listen = "http://$host:$port";

get '/' => sub{ 
   my $self = shift;
   $self->stash(ws_location => $self->url_for('ws')->to_abs);
   $self->render(template=>'ws_page')
};
get '/pub' => sub{
   $H->{r}->publish(g => 'foo');
   shift->render(text=>'published')
};

# MOVE some old stuff tries to ->send stuff on init, ux saves..
$H = H->new({name => 'S', style => 'stylehut', listen => $listen});

# This action will render a template
websocket '/ws' => sub {
    my $mojo = shift;

    eval { 
    $H->{G}->w(websocket => { M => $mojo });

    $H->{G}->w('stylehut/play');
    };
    say "Eerror\n\n$@" if $@;
    $@ = "";
};
app->secrets([readlink '/home/s/stylehouse/msecret']);
say "\n\n        listen to $listen\n";
push @{app->static->paths}, '/home/s/styleshed/public';
app->start('daemon', '--listen' => "$listen");
 #c
__DATA__
@@ws_page.html.ep
<!DOCTYPE html>
<html><head>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js" type="text/javascript"></script>
  <script src="//h:3000/jquery.scrollTo.js"></script>
</head><body style="background: url('i/greencush.jpg'); background: black; position:absolute; color: #0f2; overflow:hidden; height:100%; width:100%;">

    <div id='msgs' style="white-space: pre;position:absolute;left:0em;bottom:0em;width:22%;min-height:100%; overflow:hidden;padding:0.2em;"> </div>
    <div id='ux' style="position:absolute;right:0em;width:88%;height:100%; overflow:hidden;"> </div>

    <script type="text/javascript">
    var conn;
    var C;
    var fail = 0;
    var a = {};
    a.e = function(e) {
        console.log("xut "+e);
        eval(e);
    };
    a.m = function(e) {
        var c = e.substr(0,1);
        if (c == " ") {
            a.e(e);
        }
        else {
          if (c == ".") {
            e = '<span style="font-size:66%">'+e+'</span>';
          }
            a.c(e);
        }
    };
    a.c = function(e) {
        $('#msgs').append(e+"\n");
        //$('body').scrollTo('100%', 0);
    };

    function connect() {
       conn = new WebSocket('<%= $ws_location %>');

       conn.onmessage = function  (event) {
           var e = event.data;
           a.m(e);
       };
       conn.onopen = function () {
          a.c("connected.\n");
       };
       conn.onclose = function () {
          a.c("closed.\n");
          reconnect();
       };
    };
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


    $(document).ready(connect);
    </script>


    </body></html>

'stylehouse'