use strict;
use warnings;
use Scriptalicious;
use Test::More 'no_plan';
start_timer();
require_ok 'scap.pl';
diag "required ".show_delta();

my $g1 = new Graph("test1");
my $g1n1 = $g1->spawn({color => "yellow"});
my $g1n2 = $g1->spawn({color => "red"});
$g1n1->link($g1n2);

is(displow($g1n1)."\n", <<"", "displows");
Node {"color":"yellow"}
 Node {"color":"red"}

for (qw{red red red red orange vermillion}) {
    my $n = $g1n2->spawn({color => $_});
    /orange/ && $n->link($g1n1);
}

is(displow($g1n1)."\n", <<"", "displows");
Node {"color":"yellow"}
 Node {"color":"red"}
  Node {"color":"red"}
  Node {"color":"red"}
  Node {"color":"red"}
  Node {"color":"red"}
  Node {"color":"vermillion"}
 Node {"color":"orange"}

diag "done ".show_delta();

#do_stuff();

diag "done ".show_delta();
