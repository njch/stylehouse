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
    
};

sub tosvg {
    
                   var l = inst.slice(1);
            var text = svg.text(l[0], l[1] + 12, l[2], l[3]);
            $(text)
                .bind('click', lab_Click);


app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>stylehouse</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <style type="text/css">
    @import "jquery.svg.css";
    </style>
    <script type="text/javascript" src="jquery.svg.js"></script>
    <script type="text/javascript" src="jquery.svganim.js"></script>
    <script type="text/javascript" src="scope.js"></script></head>
    <body style="background: #ab6; font-family: monospace">
    <div id="view" style="background: #ce9"></div>
    </body>
</html>

