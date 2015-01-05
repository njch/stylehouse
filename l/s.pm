#!/usr/bin/env perl
package S;
use Mojo::IOLoop;
use common::sense;

use lib 'l';
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

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

9

