#!/usr/bin/perl
# copyright Steve Craig 2014
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
my $jsoner = JSON::XS->new->allow_nonref;
use List::MoreUtils qw"uniq";
use Storable 'dclone';
use File::Slurp;
use Scriptalicious;
use Carp 'confess';
use v5.18;
say "\n\n\nwe are $0";

=pod

hostinfo
for modules, IPs, files, everything
anything storage upgradable to sticky schemas
modules create a view div, fill it with spans
the spans' ids reach back to the module and/or controller it came from
passing it the whole element and "click" or whatever
lets eval everything from a WebSocket on the client

=cut

#!/usr/bin/env perl
use Mojolicious::Lite;

use lib 'lib';
use Hostinfo;

get '/' => 'index';

websocket '/stylehouse' => sub {
    my $self = shift;

    $self->app->log->info("WebSocket opened");
    
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);

    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->app->log->info("WebSocket: $msg");

        if ($msg eq "Hello!") {
            my $code = encode_jquery(directoria("/home/s/Music"));
            $self->send($code);
        }
        elsif ($msg =~ /^Width: (\d+)px$/) {
            $self->hostinfo->set(width => $1); # per client?
        }
        elsif ($msg =~ /^dclick: (.+)$/s) {
            # route to $1
        }
        else {
            $self->send("// echo: $msg");
        }
    });

    $self->send("ws.send('Width: '+\$('#view').width()+'px')");
    # connect above dispatcher to controllery
    # ask for screen width, etc from client

    $self->on(finish => sub {
      my ($self, $code, $reason) = @_;
      $self->app->log->debug("WebSocket closed with status $code.");
    });

};

helper hostinfo => sub { state $hostinfo = Hostinfo->new };

sub directoria {
    my @etc = capture("ls", "-lh", "/home/s");
    my $i = 0;
    return map {
        s/\n$//s;
        { type => "label",
          id => "directoria-".$i++,
          top => 10 * $i,
          left => 20,
          value => "$_", } } @etc;
}
sub encode_jquery {
    my @js;
    my @es = @_;
    for my $e (@es) {
        if ($e->{type} eq "label") {
            my $lspan = '<span class="data" style="'
                .'top: '.($e->{top}).'px; '
                .'left: '.($e->{left}).'px;"'
                .($e->{id} ? ' id="'.$e->{id}.'"' : '')
                .'>'.$e->{value}.'</span>';
            
            push @js, "  \$('#view').append('$lspan');\n";
        }
        else {
            die anydump($e);
        }
    }
    if (@js) {
        # TODO controllers create views
        push @js, "  \$('#view').delegate('.data', 'click', function (event) {
            var data = {
                id: event.target.id,
                value: event.target.innerText,
            };
            ws.send('dClick '+JSON.stringify(data))
        })
";
    }

    return join("", @js);
};


app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>stylehouse</title>
    <script type="text/javascript" src="jquery-1.11.0.js"></script></head>
    <script>
      var ws = new WebSocket('<%= url_for('stylehouse')->to_abs %>');

      // Incoming messages
      ws.onmessage = function(event) {
        console.log(event.data);
        eval(event.data);

      };
      
      ws.onopen = function() {
        ws.send('Hello!');
      }
    </script>
    <style type="text/css">
    @import "jquery.svg.css";
    .data {
        position: absolute;
        white-space: pre;
    }
    </style>
    <body style="background: #ab6; font-family: monospace">
    <div id="view" class="view" style="position: relative; background: #ce9; height: 400px;"></div>
    </body>
</html>

