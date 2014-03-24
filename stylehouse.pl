#!/usr/bin/perl
# copyright Steve Craig 2014
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Storable 'dclone';
use File::Slurp;
use Scriptalicious;
use Carp 'confess';
use v5.10;
say "\n\n\nwe are $0";

#!/usr/bin/env perl
use Mojolicious::Lite;

get '/' => 'index';

get '/hello' => sub {
    my $mojo = shift;
    $mojo->tosvg(["label", 10, 40, "EEEEEEEEEEEEE"]);
};
get '/nothing' => sub {
    my $mojo = shift;
    $mojo->render(json => 'thing');
};

*Mojolicious::Controller::tosvg = sub {
    my $mojo = shift;
    my @js;
    for my $t (@_) {
        my ($what, @p) = @$t;
        if ($what eq "label") {
            push @js, "
            console.log('it works');
            console.log('it works');
            ";
            my $nothing = "
            var text = svg.text(svg, ".($p[0] + 12).", $p[1], '$p[2]');
                ";
        }
        else {
            die "$what";
        }
    }

    $mojo->render(json => join("", @js));
};

app->start;
__DATA__
#            jQuery(text)
#                .bind('click', lab_Click);

@@ index.html.ep
<!doctype html><html>
    <head><title>stylehouse</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <style type="text/css">
    @import "jquery.svg.css";
    </style>
    <script type="text/javascript" src="jquery.svg.js"></script>
    <script type="text/javascript" src="jquery.svganim.js"></script>
    <script type="text/javascript" src="stylehouse.js"></script></head>
    <body style="background: #ab6; font-family: monospace">
    <div id="view" style="background: #ce9"></div>
    </body>
</html>

