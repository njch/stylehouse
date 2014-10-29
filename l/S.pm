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
$H = H->new({name => 'S', style => 'stylehut'});

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
app->start('daemon', '--listen' => "$listen");

__DATA__
@@ws_page.$html->{ep}
<!DOCTYPE html>
<html><head>
<script src="//$ajax->{googleapis}->{com}/ajax/libs/jquery/1.8.0/jquery.$min->{js}" type="text/javascript"></script>
</head><body style="background: url('i/greencush.jpg'); background: black; color: #0f2;">

    <h1>websocket.</h1>
    <div id='msgs'> </div>

    <script type="text/javascript">
    var conn;
    var C;
    var fail = 0;

    function connect() {
       conn = ne$G->w("WebSocket", { '<%= $ws_location %>' });

       $conn->{onmessage} = function  (event) {
          $('#msgs').append('msg: '+event.data +"<br />");
       };
       $conn->{onopen} = function () {
          $('#msgs').append("connected.\n");
       };
       $conn->{onclose} = function () {
          $('#msgs').append("closed.\n");
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

    <a href="/pub">pub</a>


    </body></html>

'stylehouse'