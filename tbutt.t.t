use strict;
use warnings;
use Scriptalicious;
use Test::More 'no_plan';
start_timer();
require_ok 'butter.pl';
diag "required ".show_delta();

do { # {{{
my $g1 = new Graph("test1");
my $g1n1 = $g1->spawn({color => "yellow"});
my $g1n2 = $g1->spawn({color => "red"});
$g1n1->link($g1n2);

is(displow($g1n1)."\n", <<"", "displows");
N(test1) {"color":"yellow"}
 N(test1) {"color":"red"}

for (qw{red red red red orange vermillion}) {
    my $n = $g1n2->spawn({color => $_});
    /orange/ && $n->link($g1n1);
}

is(displow($g1n1)."\n", <<"", "displows");
N(test1) {"color":"yellow"}
 N(test1) {"color":"red"}
  N(test1) {"color":"red"}
  N(test1) {"color":"red"}
  N(test1) {"color":"red"}
  N(test1) {"color":"red"}
  N(test1) {"color":"vermillion"}
 N(test1) {"color":"orange"}

diag "done ".show_delta();

#do_stuff();

diag "done ".show_delta();

my $g2 = new Graph();
my $g3 = new Graph();
my $g4 = new Graph();

ok(exists($main::graphs{unnamed2}) && exists($main::graphs{unnamed3}), "duplicate names incremented");

$g1n1->spawn({del => "rigor"});
$g1n1->spawn("whats");
my $nhid = $g1n1->spawn({ids => {}});
say "Yeus";
my $finded = $g1n1->linked("{ids => ...}");
is($nhid, $finded, "YEUS!");

my $ided = $g1n1->spawn({});
my $ed = $g1n1->linked("#jesus");
ok (!$ed, "no jesus");

$ided->id("jesus");
$ed = $g1n1->linked("#jesus");
ok ($ed eq $ided, "jesus!");

my $crap = $ed->spawn("#crap");
ok !$ed->linked("#crap"), "no not id";
$crap->id("crap");
ok $ed->linked("#crap"), "id!";

my @ed_links = $ed->linked;
is scalar(@ed_links), 2, "ed links to 2";
my $nuns = goof($ed, "+ #nuns {}");
ok ref $nuns->{thing} eq "HASH", "nuns! (autovivified)";
ok $ed->linked('#nuns') eq $nuns, "yeah nuns!";
my $samenuns = goof($ed, "+ #nuns {}");
is $nuns, $samenuns, "same nuns";
@ed_links = $ed->linked;
is scalar(@ed_links), 3, "ed links to 3, now";

my $del = $g1n1->linked("{del => ...}");
is $del->thing->{del}, "rigor", "del => rigor";
}; # }}}

say "";
say "";

our ($sttus, $drawings);
package NonMojo; # {{{
use strict;
use warnings;
sub new { shift; bless {@_} => "NonMojo" }
sub param {
    my $self = shift;
    my $what = shift;
    my $val = $self->{param}->{$what};
    return $val;
}
sub render {};
sub svg {
    return main::procure_svg();
}
sub sttus { shift; $main::sttus = [@_]; }
sub drawings { shift; $main::drawings = [@_]; }
package main;
sub moje {
    $sttus = undef;
    $drawings = undef;
    NonMojo->new(param => {id => shift});
} # }}}
do {
    my $id = $main::whereto->[1]->{id};
    say "ID: $id";
    my $mojo = moje($id);
    hello($mojo);
    $main::us->spawn({width => 1427});
    get_object($mojo);
    use Storable 'dclone';
    my $got = Dump(dclone $drawings);
    my $expected = <<''; # {{{
--- 
- 
  - clear
- 
  - status
  - For N(codes) sub get_object (0x9b03a40)
- 
  - boxen
  - 10
  - 58
  - 18
  - 18
  - 
    class: 0x9b03a40oxble 3a4 0x9b03a40
    fill: 3a4
    id: 0x9b03a40
    name: sub get_object 0x9b03a40
- 
  - label
  - 30
  - 60
  - N(codes) sub get_object (0x9b03a40)
  - 
    class: 0x9b03a40oxble 3a4 0x9b03a40
    font-weight: bold
    id: 0x9b03a40
    name: sub get_object 0x9b03a40
- 
  - boxen
  - 30
  - 78
  - 18
  - 18
  - 
    class: 0x9b5d2d8oxble d2d 0x9b5d2d8
    fill: d2d
    id: 0x9b5d2d8
    name: $code 0x9b5d2d8
- 
  - label
  - 50
  - 80
  - "    my $self = shift;"
  - 
    class: 0x9b5d2d8oxble-1 d2d 0x9b5d2d8
    id: 0x9b5d2d8-1
    name: $code 0x9b5d2d8
- 
  - label
  - 50
  - 94
  - "    my $id = $self->param('id')"
  - 
    class: 0x9b5d2d8oxble-2 d2d 0x9b5d2d8
    id: 0x9b5d2d8-2
    name: $code 0x9b5d2d8
- 
  - label
  - 90
  - 108
  - "        || die \"no id\";"
  - 
    class: 0x9b5d2d8oxble-3 d2d 0x9b5d2d8
    id: 0x9b5d2d8-3
    name: $code 0x9b5d2d8
- 
  - label
  - 50
  - 122
  - "    my $object = get_linked_object_by_memory_address($id)"
  - 
    class: 0x9b5d2d8oxble-4 d2d 0x9b5d2d8
    id: 0x9b5d2d8-4
    name: $code 0x9b5d2d8
- 
  - label
  - 90
  - 136
  - "        || return $self->sttus(\"$id no longer exists!\");"
  - 
    class: 0x9b5d2d8oxble-5 d2d 0x9b5d2d8
    id: 0x9b5d2d8-5
    name: $code 0x9b5d2d8
- 
  - label
  - 50
  - 150
  - "    unless (ref $object eq \"Node\") {"
  - 
    class: 0x9b5d2d8oxble-6 d2d 0x9b5d2d8
    id: 0x9b5d2d8-6
    name: $code 0x9b5d2d8
- 
  - label
  - 90
  - 164
  - "        return $self->sttus(\"don't like to objectify \".ref $object);"
  - 
    class: 0x9b5d2d8oxble-7 d2d 0x9b5d2d8
    id: 0x9b5d2d8-7
    name: $code 0x9b5d2d8
- 
  - label
  - 50
  - 178
  - "    }"
  - 
    class: 0x9b5d2d8oxble-8 d2d 0x9b5d2d8
    id: 0x9b5d2d8-8
    name: $code 0x9b5d2d8
- 
  - boxen
  - 30
  - 210
  - 18
  - 18
  - 
    class: 0x9b5f5a8oxble f5a 0x9b5f5a8
    fill: f5a
    id: 0x9b5f5a8
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 212
  - "    # find the VIEWED graph: existing subset and svg info"
  - 
    class: 0x9b5f5a8oxble-1 f5a 0x9b5f5a8
    id: 0x9b5f5a8-1
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 226
  - "    my @viewed = grep { ref $_->{thing} eq \"Graph\""
  - 
    class: 0x9b5f5a8oxble-2 f5a 0x9b5f5a8
    id: 0x9b5f5a8-2
    name: $code 0x9b5f5a8
- 
  - label
  - 250
  - 240
  - "                        && $_->{thing}->{name} =~ \"^object-examination\" } $us->linked();"
  - 
    class: 0x9b5f5a8oxble-3 f5a 0x9b5f5a8
    id: 0x9b5f5a8-3
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 254
  - "    my (@etc, $viewed) = @viewed;"
  - 
    class: 0x9b5f5a8oxble-4 f5a 0x9b5f5a8
    id: 0x9b5f5a8-4
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 268
  - "    if (@etc) {"
  - 
    class: 0x9b5f5a8oxble-5 f5a 0x9b5f5a8
    id: 0x9b5f5a8-5
    name: $code 0x9b5f5a8
- 
  - label
  - 90
  - 282
  - "        moan \"Viewedes\";"
  - 
    class: 0x9b5f5a8oxble-6 f5a 0x9b5f5a8
    id: 0x9b5f5a8-6
    name: $code 0x9b5f5a8
- 
  - label
  - 90
  - 296
  - "        $us->unlink($_) for @etc;"
  - 
    class: 0x9b5f5a8oxble-7 f5a 0x9b5f5a8
    id: 0x9b5f5a8-7
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 310
  - "    }"
  - 
    class: 0x9b5f5a8oxble-8 f5a 0x9b5f5a8
    id: 0x9b5f5a8-8
    name: $code 0x9b5f5a8
- 
  - label
  - 50
  - 324
  - "    ($viewed, my $viewed_node) = ($viewed->thing, $viewed) if $viewed;"
  - 
    class: 0x9b5f5a8oxble-9 f5a 0x9b5f5a8
    id: 0x9b5f5a8-9
    name: $code 0x9b5f5a8
- 
  - boxen
  - 30
  - 356
  - 18
  - 18
  - 
    class: 0x9b5f5c8oxble f5c 0x9b5f5c8
    fill: f5c
    id: 0x9b5f5c8
    name: $code 0x9b5f5c8
- 
  - label
  - 50
  - 358
  - "    if ($viewed && $viewed->first && $viewed->first->thing.\"\" eq $object) {"
  - 
    class: 0x9b5f5c8oxble-1 f5c 0x9b5f5c8
    id: 0x9b5f5c8-1
    name: $code 0x9b5f5c8
- 
  - label
  - 90
  - 372
  - "        return $self->sttus(\"same diff\");"
  - 
    class: 0x9b5f5c8oxble-2 f5c 0x9b5f5c8
    id: 0x9b5f5c8-2
    name: $code 0x9b5f5c8
- 
  - label
  - 50
  - 386
  - "    }"
  - 
    class: 0x9b5f5c8oxble-3 f5c 0x9b5f5c8
    id: 0x9b5f5c8-3
    name: $code 0x9b5f5c8
- 
  - boxen
  - 30
  - 418
  - 18
  - 18
  - 
    class: 0x9b5d0f8oxble d0f 0x9b5d0f8
    fill: d0f
    id: 0x9b5d0f8
    name: $code 0x9b5d0f8
- 
  - label
  - 50
  - 420
  - "    my (@drawings, @animations, @removals);"
  - 
    class: 0x9b5d0f8oxble-1 d0f 0x9b5d0f8
    id: 0x9b5d0f8-1
    name: $code 0x9b5d0f8
- 
  - boxen
  - 30
  - 452
  - 18
  - 18
  - 
    class: 0x9b5f668oxble f66 0x9b5f668
    fill: f66
    id: 0x9b5f668
    name: $code 0x9b5f668
- 
  - label
  - 50
  - 454
  - "    # TODO this is a travel()/search() result-as-graph idea"
  - 
    class: 0x9b5f668oxble-1 f66 0x9b5f668
    id: 0x9b5f668-1
    name: $code 0x9b5f668
- 
  - label
  - 50
  - 468
  - "    my $exam = $us->spawn(Graph->new('object-examination'));"
  - 
    class: 0x9b5f668oxble-2 f66 0x9b5f668
    id: 0x9b5f668-2
    name: $code 0x9b5f668
- 
  - label
  - 50
  - 482
  - "    $exam = $exam->{thing};"
  - 
    class: 0x9b5f668oxble-3 f66 0x9b5f668
    id: 0x9b5f668-3
    name: $code 0x9b5f668
- 
  - boxen
  - 30
  - 514
  - 18
  - 18
  - 
    class: 0x9b5cf98oxble cf9 0x9b5cf98
    fill: cf9
    id: 0x9b5cf98
    name: $code 0x9b5cf98
- 
  - label
  - 50
  - 516
  - "    my $trav = Travel->new(ignore =>"
  - 
    class: 0x9b5cf98oxble-1 cf9 0x9b5cf98
    id: 0x9b5cf98-1
    name: $code 0x9b5cf98
- 
  - label
  - 90
  - 530
  - "        [\"->{no_of_links}\", \"->{iggy}\", \"findable_objects\"]);"
  - 
    class: 0x9b5cf98oxble-2 cf9 0x9b5cf98
    id: 0x9b5cf98-2
    name: $code 0x9b5cf98
- 
  - boxen
  - 30
  - 562
  - 18
  - 18
  - 
    class: 0x9b5f778oxble f77 0x9b5f778
    fill: f77
    id: 0x9b5f778
    name: $code 0x9b5f778
- 
  - label
  - 50
  - 564
  - "    my $head;"
  - 
    class: 0x9b5f778oxble-1 f77 0x9b5f778
    id: 0x9b5f778-1
    name: $code 0x9b5f778
- 
  - label
  - 50
  - 578
  - "    $trav->travel($object, sub {"
  - 
    class: 0x9b5f778oxble-2 f77 0x9b5f778
    id: 0x9b5f778-2
    name: $code 0x9b5f778
- 
  - label
  - 90
  - 592
  - "        my ($G, $ex) = @_;"
  - 
    class: 0x9b5f778oxble-3 f77 0x9b5f778
    id: 0x9b5f778-3
    name: $code 0x9b5f778
- 
  - label
  - 90
  - 606
  - "        if ($ex->{previous}) {"
  - 
    class: 0x9b5f778oxble-4 f77 0x9b5f778
    id: 0x9b5f778-4
    name: $code 0x9b5f778
- 
  - label
  - 130
  - 620
  - "            my $found = $exam"
  - 
    class: 0x9b5f778oxble-5 f77 0x9b5f778
    id: 0x9b5f778-5
    name: $code 0x9b5f778
- 
  - label
  - 170
  - 634
  - "                ->find($ex->{previous});"
  - 
    class: 0x9b5f778oxble-6 f77 0x9b5f778
    id: 0x9b5f778-6
    name: $code 0x9b5f778
- 
  - label
  - 130
  - 648
  - "            $found"
  - 
    class: 0x9b5f778oxble-7 f77 0x9b5f778
    id: 0x9b5f778-7
    name: $code 0x9b5f778
- 
  - label
  - 170
  - 662
  - "                ->spawn($G, $ex->{via_link});"
  - 
    class: 0x9b5f778oxble-8 f77 0x9b5f778
    id: 0x9b5f778-8
    name: $code 0x9b5f778
- 
  - label
  - 90
  - 676
  - "        }"
  - 
    class: 0x9b5f778oxble-9 f77 0x9b5f778
    id: 0x9b5f778-9
    name: $code 0x9b5f778
- 
  - label
  - 90
  - 690
  - "        else {"
  - 
    class: 0x9b5f778oxble-10 f77 0x9b5f778
    id: 0x9b5f778-10
    name: $code 0x9b5f778
- 
  - label
  - 130
  - 704
  - "            $head = $exam->spawn($G);"
  - 
    class: 0x9b5f778oxble-11 f77 0x9b5f778
    id: 0x9b5f778-11
    name: $code 0x9b5f778
- 
  - label
  - 90
  - 718
  - "        }"
  - 
    class: 0x9b5f778oxble-12 f77 0x9b5f778
    id: 0x9b5f778-12
    name: $code 0x9b5f778
- 
  - label
  - 50
  - 732
  - "    });"
  - 
    class: 0x9b5f778oxble-13 f77 0x9b5f778
    id: 0x9b5f778-13
    name: $code 0x9b5f778
- 
  - boxen
  - 30
  - 764
  - 18
  - 18
  - 
    class: 0x9b5f7f8oxble f7f 0x9b5f7f8
    fill: f7f
    id: 0x9b5f7f8
    name: $code 0x9b5f7f8
- 
  - label
  - 50
  - 766
  - "    # Just an exercise, we can do this more casually in the svg build"
  - 
    class: 0x9b5f7f8oxble-1 f7f 0x9b5f7f8
    id: 0x9b5f7f8-1
    name: $code 0x9b5f7f8
- 
  - label
  - 50
  - 780
  - "    $trav->travel($head,"
  - 
    class: 0x9b5f7f8oxble-2 f7f 0x9b5f7f8
    id: 0x9b5f7f8-2
    name: $code 0x9b5f7f8
- 
  - label
  - 90
  - 794
  - "        all_links => sub {"
  - 
    class: 0x9b5f7f8oxble-3 f7f 0x9b5f7f8
    id: 0x9b5f7f8-3
    name: $code 0x9b5f7f8
- 
  - label
  - 130
  - 808
  - "            $_[0]->spawn({iggy => 1, no_of_links => scalar @{$_[2]}})"
  - 
    class: 0x9b5f7f8oxble-4 f7f 0x9b5f7f8
    id: 0x9b5f7f8-4
    name: $code 0x9b5f7f8
- 
  - label
  - 90
  - 822
  - "        },"
  - 
    class: 0x9b5f7f8oxble-5 f7f 0x9b5f7f8
    id: 0x9b5f7f8-5
    name: $code 0x9b5f7f8
- 
  - label
  - 50
  - 836
  - "    );"
  - 
    class: 0x9b5f7f8oxble-6 f7f 0x9b5f7f8
    id: 0x9b5f7f8-6
    name: $code 0x9b5f7f8
- 
  - boxen
  - 30
  - 868
  - 18
  - 18
  - 
    class: 0x9b5ce58oxble ce5 0x9b5ce58
    fill: ce5
    id: 0x9b5ce58
    name: $code 0x9b5ce58
- 
  - label
  - 50
  - 870
  - "    my $svg = $self->svg;"
  - 
    class: 0x9b5ce58oxble-1 ce5 0x9b5ce58
    id: 0x9b5ce58-1
    name: $code 0x9b5ce58
- 
  - boxen
  - 30
  - 902
  - 18
  - 18
  - 
    class: 0x9b5f8e8oxble f8e 0x9b5f8e8
    fill: f8e
    id: 0x9b5f8e8
    name: $code 0x9b5f8e8
- 
  - label
  - 50
  - 904
  - "    my $nameidcolor = sub {"
  - 
    class: 0x9b5f8e8oxble-1 f8e 0x9b5f8e8
    id: 0x9b5f8e8-1
    name: $code 0x9b5f8e8
- 
  - label
  - 90
  - 918
  - "        my $summarised = shift;"
  - 
    class: 0x9b5f8e8oxble-2 f8e 0x9b5f8e8
    id: 0x9b5f8e8-2
    name: $code 0x9b5f8e8
- 
  - label
  - 90
  - 932
  - "        if ($summarised =~"
  - 
    class: 0x9b5f8e8oxble-3 f8e 0x9b5f8e8
    id: 0x9b5f8e8-3
    name: $code 0x9b5f8e8
- 
  - label
  - 130
  - 946
  - "            m{^(?:N\\(.+?\\) )*(.+) \\((0x...(...).)\\)$}) {"
  - 
    class: 0x9b5f8e8oxble-4 f8e 0x9b5f8e8
    id: 0x9b5f8e8-4
    name: $code 0x9b5f8e8
- 
  - label
  - 130
  - 960
  - "            my ($name, $id, $color) = ($1, $2, $3);"
  - 
    class: 0x9b5f8e8oxble-5 f8e 0x9b5f8e8
    id: 0x9b5f8e8-5
    name: $code 0x9b5f8e8
- 
  - label
  - 130
  - 974
  - "            $name = \"$name $id\";"
  - 
    class: 0x9b5f8e8oxble-6 f8e 0x9b5f8e8
    id: 0x9b5f8e8-6
    name: $code 0x9b5f8e8
- 
  - label
  - 130
  - 988
  - "            return ($name, $id, $color);"
  - 
    class: 0x9b5f8e8oxble-7 f8e 0x9b5f8e8
    id: 0x9b5f8e8-7
    name: $code 0x9b5f8e8
- 
  - label
  - 90
  - 1002
  - "        }"
  - 
    class: 0x9b5f8e8oxble-8 f8e 0x9b5f8e8
    id: 0x9b5f8e8-8
    name: $code 0x9b5f8e8
- 
  - label
  - 90
  - 1016
  - "        else {"
  - 
    class: 0x9b5f8e8oxble-9 f8e 0x9b5f8e8
    id: 0x9b5f8e8-9
    name: $code 0x9b5f8e8
- 
  - label
  - 130
  - 1030
  - "            return (\"$summarised\", \"???\", \"000\");"
  - 
    class: 0x9b5f8e8oxble-10 f8e 0x9b5f8e8
    id: 0x9b5f8e8-10
    name: $code 0x9b5f8e8
- 
  - label
  - 90
  - 1044
  - "        }"
  - 
    class: 0x9b5f8e8oxble-11 f8e 0x9b5f8e8
    id: 0x9b5f8e8-11
    name: $code 0x9b5f8e8
- 
  - label
  - 50
  - 1058
  - "    };"
  - 
    class: 0x9b5f8e8oxble-12 f8e 0x9b5f8e8
    id: 0x9b5f8e8-12
    name: $code 0x9b5f8e8
- 
  - boxen
  - 30
  - 1090
  - 18
  - 18
  - 
    class: 0x9b5f938oxble f93 0x9b5f938
    fill: f93
    id: 0x9b5f938
    name: $code 0x9b5f938
- 
  - label
  - 50
  - 1092
  - "    my ($ids) = grep { ref $_->{thing} eq \"HASH\""
  - 
    class: 0x9b5f938oxble-1 f93 0x9b5f938
    id: 0x9b5f938-1
    name: $code 0x9b5f938
- 
  - label
  - 90
  - 1106
  - "        && $_->{thing}->{ids} } $us->linked;"
  - 
    class: 0x9b5f938oxble-2 f93 0x9b5f938
    id: 0x9b5f938-2
    name: $code 0x9b5f938
- 
  - label
  - 50
  - 1120
  - "    $ids ||= do { $us->spawn({ids => {}})->{ids} };"
  - 
    class: 0x9b5f938oxble-3 f93 0x9b5f938
    id: 0x9b5f938-3
    name: $code 0x9b5f938
- 
  - boxen
  - 30
  - 1152
  - 18
  - 18
  - 
    class: 0x9b5ccd8oxble ccd 0x9b5ccd8
    fill: ccd
    id: 0x9b5ccd8
    name: $code 0x9b5ccd8
- 
  - label
  - 50
  - 1154
  - "    $DB::single = 1;"
  - 
    class: 0x9b5ccd8oxble-1 ccd 0x9b5ccd8
    id: 0x9b5ccd8-1
    name: $code 0x9b5ccd8
- 
  - label
  - 50
  - 1168
  - "    my ($x, $y) = (30, 40);"
  - 
    class: 0x9b5ccd8oxble-2 ccd 0x9b5ccd8
    id: 0x9b5ccd8-2
    name: $code 0x9b5ccd8
- 
  - boxen
  - 30
  - 1200
  - 18
  - 18
  - 
    class: 0x9b5f9f8oxble f9f 0x9b5f9f8
    fill: f9f
    id: 0x9b5f9f8
    name: $code 0x9b5f9f8
- 
  - label
  - 50
  - 1202
  - "    $trav->travel($head, sub {"
  - 
    class: 0x9b5f9f8oxble-1 f9f 0x9b5f9f8
    id: 0x9b5f9f8-1
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1216
  - "        my ($G, $ex) = @_;"
  - 
    class: 0x9b5f9f8oxble-2 f9f 0x9b5f9f8
    id: 0x9b5f9f8-2
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1230
  - "        my $thing = $G->{thing};"
  - 
    class: 0x9b5f9f8oxble-3 f9f 0x9b5f9f8
    id: 0x9b5f9f8-3
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1244
  - "        return if $thing eq \"svg\";"
  - 
    class: 0x9b5f9f8oxble-4 f9f 0x9b5f9f8
    id: 0x9b5f9f8-4
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1258
  - "        return if $thing->{iggy};"
  - 
    class: 0x9b5f9f8oxble-5 f9f 0x9b5f9f8
    id: 0x9b5f9f8-5
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1272
  - "        die \"urm \".Dump($thing) unless ref $thing eq \"Node\";"
  - 
    class: 0x9b5f9f8oxble-6 f9f 0x9b5f9f8
    id: 0x9b5f9f8-6
    name: $code 0x9b5f9f8
- 
  - label
  - 90
  - 1286
  - "        $thing = $thing->{thing};"
  - 
    class: 0x9b5f9f8oxble-7 f9f 0x9b5f9f8
    id: 0x9b5f9f8-7
    name: $code 0x9b5f9f8
- 
  - boxen
  - 30
  - 1318
  - 18
  - 18
  - 
    class: 0x9b5fa48oxble fa4 0x9b5fa48
    fill: fa4
    id: 0x9b5fa48
    name: $code 0x9b5fa48
- 
  - label
  - 90
  - 1320
  - "        my $x = $x + $ex->{depth} * 20;"
  - 
    class: 0x9b5fa48oxble-1 fa4 0x9b5fa48
    id: 0x9b5fa48-1
    name: $code 0x9b5fa48
- 
  - label
  - 90
  - 1334
  - "        $y += 20;"
  - 
    class: 0x9b5fa48oxble-2 fa4 0x9b5fa48
    id: 0x9b5fa48-2
    name: $code 0x9b5fa48
- 
  - label
  - 90
  - 1348
  - "        my $stuff = summarise($G);"
  - 
    class: 0x9b5fa48oxble-3 fa4 0x9b5fa48
    id: 0x9b5fa48-3
    name: $code 0x9b5fa48
- 
  - label
  - 90
  - 1362
  - "        $stuff =~ s/^N\\($exam->{name}\\) //;"
  - 
    class: 0x9b5fa48oxble-4 fa4 0x9b5fa48
    id: 0x9b5fa48-4
    name: $code 0x9b5fa48
- 
  - boxen
  - 30
  - 1394
  - 18
  - 18
  - 
    class: 0x9b5fa98oxble fa9 0x9b5fa98
    fill: fa9
    id: 0x9b5fa98
    name: $code 0x9b5fa98
- 
  - label
  - 90
  - 1396
  - "        my ($linknode) = grep { ref $_->thing eq \"HASH\""
  - 
    class: 0x9b5fa98oxble-1 fa9 0x9b5fa98
    id: 0x9b5fa98-1
    name: $code 0x9b5fa98
- 
  - label
  - 130
  - 1410
  - "            && $_->thing->{no_of_links} } $G->linked;"
  - 
    class: 0x9b5fa98oxble-2 fa9 0x9b5fa98
    id: 0x9b5fa98-2
    name: $code 0x9b5fa98
- 
  - label
  - 90
  - 1424
  - "        my $no_of_links = $linknode->thing->{no_of_links}"
  - 
    class: 0x9b5fa98oxble-3 fa9 0x9b5fa98
    id: 0x9b5fa98-3
    name: $code 0x9b5fa98
- 
  - label
  - 130
  - 1438
  - "            if $linknode;"
  - 
    class: 0x9b5fa98oxble-4 fa9 0x9b5fa98
    id: 0x9b5fa98-4
    name: $code 0x9b5fa98
- 
  - boxen
  - 30
  - 1470
  - 18
  - 18
  - 
    class: 0x9b5fb38oxble fb3 0x9b5fb38
    fill: fb3
    id: 0x9b5fb38
    name: $code 0x9b5fb38
- 
  - label
  - 90
  - 1472
  - "        my ($name, $id, $color) = $nameidcolor->($stuff);"
  - 
    class: 0x9b5fb38oxble-1 fb3 0x9b5fb38
    id: 0x9b5fb38-1
    name: $code 0x9b5fb38
- 
  - label
  - 90
  - 1486
  - "        my $oxble_uniq = uniquify_id($ids, \"${id}oxble\");"
  - 
    class: 0x9b5fb38oxble-2 fb3 0x9b5fb38
    id: 0x9b5fb38-2
    name: $code 0x9b5fb38
- 
  - label
  - 90
  - 1500
  - "        $ids->{$oxble_uniq} = undef;"
  - 
    class: 0x9b5fb38oxble-3 fb3 0x9b5fb38
    id: 0x9b5fb38-3
    name: $code 0x9b5fb38
- 
  - label
  - 90
  - 1514
  - "        my $settings = sub {"
  - 
    class: 0x9b5fb38oxble-4 fb3 0x9b5fb38
    id: 0x9b5fb38-4
    name: $code 0x9b5fb38
- 
  - label
  - 130
  - 1528
  - "            my $kind = shift;"
  - 
    class: 0x9b5fb38oxble-5 fb3 0x9b5fb38
    id: 0x9b5fb38-5
    name: $code 0x9b5fb38
- 
  - label
  - 130
  - 1542
  - "            my $settings = { fill => $color, id => $id,"
  - 
    class: 0x9b5fb38oxble-6 fb3 0x9b5fb38
    id: 0x9b5fb38-6
    name: $code 0x9b5fb38
- 
  - label
  - 170
  - 1556
  - "                class => [$oxble_uniq, $color, $id], name => $name };"
  - 
    class: 0x9b5fb38oxble-7 fb3 0x9b5fb38
    id: 0x9b5fb38-7
    name: $code 0x9b5fb38
- 
  - label
  - 130
  - 1570
  - "            return $settings;"
  - 
    class: 0x9b5fb38oxble-8 fb3 0x9b5fb38
    id: 0x9b5fb38-8
    name: $code 0x9b5fb38
- 
  - label
  - 90
  - 1584
  - "        };"
  - 
    class: 0x9b5fb38oxble-9 fb3 0x9b5fb38
    id: 0x9b5fb38-9
    name: $code 0x9b5fb38
- 
  - boxen
  - 30
  - 1616
  - 18
  - 18
  - 
    class: 0x9b5fb88oxble fb8 0x9b5fb88
    fill: fb8
    id: 0x9b5fb88
    name: $code 0x9b5fb88
- 
  - label
  - 90
  - 1618
  - "        my $box_set = $settings->(\"boxen\");"
  - 
    class: 0x9b5fb88oxble-1 fb8 0x9b5fb88
    id: 0x9b5fb88-1
    name: $code 0x9b5fb88
- 
  - label
  - 90
  - 1632
  - "        $svg->link($G,"
  - 
    class: 0x9b5fb88oxble-2 fb8 0x9b5fb88
    id: 0x9b5fb88-2
    name: $code 0x9b5fb88
- 
  - label
  - 130
  - 1646
  - "            [ \"boxen\", $x-20, $y-2, 18, 18, $box_set ]"
  - 
    class: 0x9b5fb88oxble-3 fb8 0x9b5fb88
    id: 0x9b5fb88-3
    name: $code 0x9b5fb88
- 
  - label
  - 90
  - 1660
  - "        );"
  - 
    class: 0x9b5fb88oxble-4 fb8 0x9b5fb88
    id: 0x9b5fb88-4
    name: $code 0x9b5fb88
- 
  - boxen
  - 30
  - 1692
  - 18
  - 18
  - 
    class: 0x9b5fd48oxble fd4 0x9b5fd48
    fill: fd4
    id: 0x9b5fd48
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1694
  - "        my $lab_set = $settings->(\"label\");"
  - 
    class: 0x9b5fd48oxble-1 fd4 0x9b5fd48
    id: 0x9b5fd48-1
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1708
  - "        delete $lab_set->{fill};"
  - 
    class: 0x9b5fd48oxble-2 fd4 0x9b5fd48
    id: 0x9b5fd48-2
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1722
  - "        if ($no_of_links && $no_of_links > 1) {"
  - 
    class: 0x9b5fd48oxble-3 fd4 0x9b5fd48
    id: 0x9b5fd48-3
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 1736
  - "            $lab_set->{'font-weight'} = \"bold\";"
  - 
    class: 0x9b5fd48oxble-4 fd4 0x9b5fd48
    id: 0x9b5fd48-4
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1750
  - "        }"
  - 
    class: 0x9b5fd48oxble-5 fd4 0x9b5fd48
    id: 0x9b5fd48-5
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1764
  - "        if (ref $thing eq \"HASH\" && $thing->{code}) {"
  - 
    class: 0x9b5fd48oxble-6 fd4 0x9b5fd48
    id: 0x9b5fd48-6
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 1778
  - "            my $li = 1;"
  - 
    class: 0x9b5fd48oxble-7 fd4 0x9b5fd48
    id: 0x9b5fd48-7
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 1792
  - "            for my $line (split /\\n/, $thing->{code} ) {"
  - 
    class: 0x9b5fd48oxble-8 fd4 0x9b5fd48
    id: 0x9b5fd48-8
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1806
  - "                my ($ind) = $line =~ /^( +)/;"
  - 
    class: 0x9b5fd48oxble-9 fd4 0x9b5fd48
    id: 0x9b5fd48-9
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1820
  - "                my $x = $x + (length($ind)-4) * 10;"
  - 
    class: 0x9b5fd48oxble-10 fd4 0x9b5fd48
    id: 0x9b5fd48-10
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1834
  - "                my $lab_set = { %$lab_set };"
  - 
    class: 0x9b5fd48oxble-11 fd4 0x9b5fd48
    id: 0x9b5fd48-11
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1848
  - "                $lab_set->{class} = [ @{$lab_set->{class}} ];"
  - 
    class: 0x9b5fd48oxble-12 fd4 0x9b5fd48
    id: 0x9b5fd48-12
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1862
  - "                $lab_set->{class}->[0] .= \"-$li\";"
  - 
    class: 0x9b5fd48oxble-13 fd4 0x9b5fd48
    id: 0x9b5fd48-13
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1876
  - "                $lab_set->{id} .= \"-$li\";"
  - 
    class: 0x9b5fd48oxble-14 fd4 0x9b5fd48
    id: 0x9b5fd48-14
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1890
  - "                $svg->link($G,"
  - 
    class: 0x9b5fd48oxble-15 fd4 0x9b5fd48
    id: 0x9b5fd48-15
    name: $code 0x9b5fd48
- 
  - label
  - 210
  - 1904
  - "                    [ \"label\", $x, $y, $line, $lab_set]"
  - 
    class: 0x9b5fd48oxble-16 fd4 0x9b5fd48
    id: 0x9b5fd48-16
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1918
  - "                );"
  - 
    class: 0x9b5fd48oxble-17 fd4 0x9b5fd48
    id: 0x9b5fd48-17
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1932
  - "                $li++;"
  - 
    class: 0x9b5fd48oxble-18 fd4 0x9b5fd48
    id: 0x9b5fd48-18
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 1946
  - "                $y += 14;"
  - 
    class: 0x9b5fd48oxble-19 fd4 0x9b5fd48
    id: 0x9b5fd48-19
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 1960
  - "            }"
  - 
    class: 0x9b5fd48oxble-20 fd4 0x9b5fd48
    id: 0x9b5fd48-20
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1974
  - "        }"
  - 
    class: 0x9b5fd48oxble-21 fd4 0x9b5fd48
    id: 0x9b5fd48-21
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 1988
  - "        else {"
  - 
    class: 0x9b5fd48oxble-22 fd4 0x9b5fd48
    id: 0x9b5fd48-22
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 2002
  - "            $svg->link($G,"
  - 
    class: 0x9b5fd48oxble-23 fd4 0x9b5fd48
    id: 0x9b5fd48-23
    name: $code 0x9b5fd48
- 
  - label
  - 170
  - 2016
  - "                [ \"label\", $x, $y, $stuff, $lab_set]"
  - 
    class: 0x9b5fd48oxble-24 fd4 0x9b5fd48
    id: 0x9b5fd48-24
    name: $code 0x9b5fd48
- 
  - label
  - 130
  - 2030
  - "            );"
  - 
    class: 0x9b5fd48oxble-25 fd4 0x9b5fd48
    id: 0x9b5fd48-25
    name: $code 0x9b5fd48
- 
  - label
  - 90
  - 2044
  - "        }"
  - 
    class: 0x9b5fd48oxble-26 fd4 0x9b5fd48
    id: 0x9b5fd48-26
    name: $code 0x9b5fd48
- 
  - label
  - 50
  - 2058
  - "    });"
  - 
    class: 0x9b5fd48oxble-27 fd4 0x9b5fd48
    id: 0x9b5fd48-27
    name: $code 0x9b5fd48
- 
  - label
  - 50
  - 2072
  - "    "
  - 
    class: 0x9b5fd48oxble-28 fd4 0x9b5fd48
    id: 0x9b5fd48-28
    name: $code 0x9b5fd48
- 
  - boxen
  - 30
  - 2104
  - 18
  - 18
  - 
    class: 0x9b5fdc8oxble fdc 0x9b5fdc8
    fill: fdc
    id: 0x9b5fdc8
    name: $code 0x9b5fdc8
- 
  - label
  - 50
  - 2106
  - "    my $preserve = $exam->spawn(\"preserve\");"
  - 
    class: 0x9b5fdc8oxble-1 fdc 0x9b5fdc8
    id: 0x9b5fdc8-1
    name: $code 0x9b5fdc8
- 
  - label
  - 50
  - 2120
  - "    $trav->travel($head, sub {"
  - 
    class: 0x9b5fdc8oxble-2 fdc 0x9b5fdc8
    id: 0x9b5fdc8-2
    name: $code 0x9b5fdc8
- 
  - label
  - 90
  - 2134
  - "        my ($new, $ex) = @_;"
  - 
    class: 0x9b5fdc8oxble-3 fdc 0x9b5fdc8
    id: 0x9b5fdc8-3
    name: $code 0x9b5fdc8
- 
  - label
  - 90
  - 2148
  - "        my @old = $viewed->find($new->thing) if $viewed;"
  - 
    class: 0x9b5fdc8oxble-4 fdc 0x9b5fdc8
    id: 0x9b5fdc8-4
    name: $code 0x9b5fdc8
- 
  - label
  - 90
  - 2162
  - "        my ($old) = grep { !$_->linked($preserve) } @old;"
  - 
    class: 0x9b5fdc8oxble-5 fdc 0x9b5fdc8
    id: 0x9b5fdc8-5
    name: $code 0x9b5fdc8
- 
  - label
  - 90
  - 2176
  - "        if ($old) {"
  - 
    class: 0x9b5fdc8oxble-6 fdc 0x9b5fdc8
    id: 0x9b5fdc8-6
    name: $code 0x9b5fdc8
- 
  - label
  - 130
  - 2190
  - "            $preserve->link($old);"
  - 
    class: 0x9b5fdc8oxble-7 fdc 0x9b5fdc8
    id: 0x9b5fdc8-7
    name: $code 0x9b5fdc8
- 
  - label
  - 60
  - 2204
  - "     "
  - 
    class: 0x9b5fdc8oxble-8 fdc 0x9b5fdc8
    id: 0x9b5fdc8-8
    name: $code 0x9b5fdc8
- 
  - boxen
  - 30
  - 2236
  - 18
  - 18
  - 
    class: 0x9b5fe18oxble fe1 0x9b5fe18
    fill: fe1
    id: 0x9b5fe18
    name: $code 0x9b5fe18
- 
  - label
  - 130
  - 2238
  - "            my @olds = map { $_->{val}->[0] } $old->links($svg);"
  - 
    class: 0x9b5fe18oxble-1 fe1 0x9b5fe18
    id: 0x9b5fe18-1
    name: $code 0x9b5fe18
- 
  - label
  - 130
  - 2252
  - "            die \"hmm\" if @olds != 2;"
  - 
    class: 0x9b5fe18oxble-2 fe1 0x9b5fe18
    id: 0x9b5fe18-2
    name: $code 0x9b5fe18
- 
  - label
  - 130
  - 2266
  - "            my @news = map { $_->{val}->[0] } $new->links($svg);"
  - 
    class: 0x9b5fe18oxble-3 fe1 0x9b5fe18
    id: 0x9b5fe18-3
    name: $code 0x9b5fe18
- 
  - label
  - 130
  - 2280
  - "            die \"har\" if @news != 2;"
  - 
    class: 0x9b5fe18oxble-4 fe1 0x9b5fe18
    id: 0x9b5fe18-4
    name: $code 0x9b5fe18
- 
  - boxen
  - 30
  - 2312
  - 18
  - 18
  - 
    class: 0x9b5fc58oxble fc5 0x9b5fc58
    fill: fc5
    id: 0x9b5fc58
    name: $code 0x9b5fc58
- 
  - label
  - 130
  - 2314
  - "            my ($oxble_uniq) = split /\\s/, $olds[0]->[-1]->{class};"
  - 
    class: 0x9b5fc58oxble-1 fc5 0x9b5fc58
    id: 0x9b5fc58-1
    name: $code 0x9b5fc58
- 
  - boxen
  - 30
  - 2346
  - 18
  - 18
  - 
    class: 0x9b5feb8oxble feb 0x9b5feb8
    fill: feb
    id: 0x9b5feb8
    name: $code 0x9b5feb8
- 
  - label
  - 130
  - 2348
  - "            my $bits;"
  - 
    class: 0x9b5feb8oxble-1 feb 0x9b5feb8
    id: 0x9b5feb8-1
    name: $code 0x9b5feb8
- 
  - label
  - 130
  - 2362
  - "            for ([old => @olds], [new => @news]) {"
  - 
    class: 0x9b5feb8oxble-2 feb 0x9b5feb8
    id: 0x9b5feb8-2
    name: $code 0x9b5feb8
- 
  - label
  - 170
  - 2376
  - "                my ($e, @d) = @$_;"
  - 
    class: 0x9b5feb8oxble-3 feb 0x9b5feb8
    id: 0x9b5feb8-3
    name: $code 0x9b5feb8
- 
  - label
  - 170
  - 2390
  - "                for my $ds (@d) {"
  - 
    class: 0x9b5feb8oxble-4 feb 0x9b5feb8
    id: 0x9b5feb8-4
    name: $code 0x9b5feb8
- 
  - label
  - 210
  - 2404
  - "                    $bits->{$e}->{$ds->[0]} = $ds;"
  - 
    class: 0x9b5feb8oxble-5 feb 0x9b5feb8
    id: 0x9b5feb8-5
    name: $code 0x9b5feb8
- 
  - label
  - 170
  - 2418
  - "                }"
  - 
    class: 0x9b5feb8oxble-6 feb 0x9b5feb8
    id: 0x9b5feb8-6
    name: $code 0x9b5feb8
- 
  - label
  - 130
  - 2432
  - "            }"
  - 
    class: 0x9b5feb8oxble-7 feb 0x9b5feb8
    id: 0x9b5feb8-7
    name: $code 0x9b5feb8
- 
  - boxen
  - 30
  - 2464
  - 18
  - 18
  - 
    class: 0x9b60068oxble 006 0x9b60068
    fill: '006'
    id: 0x9b60068
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2466
  - "            my $diffs;"
  - 
    class: 0x9b60068oxble-1 006 0x9b60068
    id: 0x9b60068-1
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2480
  - "            for my $t (\"label\", \"boxen\") {"
  - 
    class: 0x9b60068oxble-2 006 0x9b60068
    id: 0x9b60068-2
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2494
  - "                $diffs->{$t}->{x} ="
  - 
    class: 0x9b60068oxble-3 006 0x9b60068
    id: 0x9b60068-3
    name: $code 0x9b60068
- 
  - label
  - 210
  - 2508
  - "                    ($bits->{new}->{$t}->[1]"
  - 
    class: 0x9b60068oxble-4 006 0x9b60068
    id: 0x9b60068-4
    name: $code 0x9b60068
- 
  - label
  - 200
  - 2522
  - "                   - $bits->{old}->{$t}->[1]);"
  - 
    class: 0x9b60068oxble-5 006 0x9b60068
    id: 0x9b60068-5
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2536
  - "                $diffs->{$t}->{y} ="
  - 
    class: 0x9b60068oxble-6 006 0x9b60068
    id: 0x9b60068-6
    name: $code 0x9b60068
- 
  - label
  - 210
  - 2550
  - "                    ($bits->{new}->{$t}->[2]"
  - 
    class: 0x9b60068oxble-7 006 0x9b60068
    id: 0x9b60068-7
    name: $code 0x9b60068
- 
  - label
  - 200
  - 2564
  - "                   - $bits->{old}->{$t}->[2]);"
  - 
    class: 0x9b60068oxble-8 006 0x9b60068
    id: 0x9b60068-8
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2578
  - "            }"
  - 
    class: 0x9b60068oxble-9 006 0x9b60068
    id: 0x9b60068-9
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2592
  - "            die \"divorcing boxen-labels\" unless"
  - 
    class: 0x9b60068oxble-10 006 0x9b60068
    id: 0x9b60068-10
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2606
  - "                $diffs->{label}->{x} == $diffs->{boxen}->{x}"
  - 
    class: 0x9b60068oxble-11 006 0x9b60068
    id: 0x9b60068-11
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2620
  - "                && $diffs->{label}->{y} == $diffs->{boxen}->{y};"
  - 
    class: 0x9b60068oxble-12 006 0x9b60068
    id: 0x9b60068-12
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2634
  - "            my $trans = $diffs->{label}->{x}.\" \".$diffs->{boxen}->{y};"
  - 
    class: 0x9b60068oxble-13 006 0x9b60068
    id: 0x9b60068-13
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2648
  - "            if ($diffs->{label}->{x} != 0 ||"
  - 
    class: 0x9b60068oxble-14 006 0x9b60068
    id: 0x9b60068-14
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2662
  - "                $diffs->{boxen}->{y} != 0) {"
  - 
    class: 0x9b60068oxble-15 006 0x9b60068
    id: 0x9b60068-15
    name: $code 0x9b60068
- 
  - label
  - 170
  - 2676
  - "                push @animations, [\"animate\", $oxble_uniq,"
  - 
    class: 0x9b60068oxble-16 006 0x9b60068
    id: 0x9b60068-16
    name: $code 0x9b60068
- 
  - label
  - 250
  - 2690
  - "                        {svgTransform => \"translate($trans)\"},"
  - 
    class: 0x9b60068oxble-17 006 0x9b60068
    id: 0x9b60068-17
    name: $code 0x9b60068
- 
  - label
  - 210
  - 2704
  - "                    300];"
  - 
    class: 0x9b60068oxble-18 006 0x9b60068
    id: 0x9b60068-18
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2718
  - "            }"
  - 
    class: 0x9b60068oxble-19 006 0x9b60068
    id: 0x9b60068-19
    name: $code 0x9b60068
- 
  - label
  - 90
  - 2732
  - "        }"
  - 
    class: 0x9b60068oxble-20 006 0x9b60068
    id: 0x9b60068-20
    name: $code 0x9b60068
- 
  - label
  - 90
  - 2746
  - "        else {"
  - 
    class: 0x9b60068oxble-21 006 0x9b60068
    id: 0x9b60068-21
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2760
  - "            my @whats = $svg->links($new);"
  - 
    class: 0x9b60068oxble-22 006 0x9b60068
    id: 0x9b60068-22
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2774
  - "            @whats = map { $_->{val}->[0] } @whats; # new: label, boxen"
  - 
    class: 0x9b60068oxble-23 006 0x9b60068
    id: 0x9b60068-23
    name: $code 0x9b60068
- 
  - label
  - 130
  - 2788
  - "            push @drawings, @whats;"
  - 
    class: 0x9b60068oxble-24 006 0x9b60068
    id: 0x9b60068-24
    name: $code 0x9b60068
- 
  - label
  - 90
  - 2802
  - "        }"
  - 
    class: 0x9b60068oxble-25 006 0x9b60068
    id: 0x9b60068-25
    name: $code 0x9b60068
- 
  - label
  - 50
  - 2816
  - "    });"
  - 
    class: 0x9b60068oxble-26 006 0x9b60068
    id: 0x9b60068-26
    name: $code 0x9b60068
- 
  - boxen
  - 30
  - 2848
  - 18
  - 18
  - 
    class: 0x9b60138oxble 013 0x9b60138
    fill: '013'
    id: 0x9b60138
    name: $code 0x9b60138
- 
  - label
  - 50
  - 2850
  - "    if ($viewed) {"
  - 
    class: 0x9b60138oxble-1 013 0x9b60138
    id: 0x9b60138-1
    name: $code 0x9b60138
- 
  - label
  - 90
  - 2864
  - "        $trav->travel($viewed->first, sub {"
  - 
    class: 0x9b60138oxble-2 013 0x9b60138
    id: 0x9b60138-2
    name: $code 0x9b60138
- 
  - label
  - 130
  - 2878
  - "            my ($G,$ex) = @_;"
  - 
    class: 0x9b60138oxble-3 013 0x9b60138
    id: 0x9b60138-3
    name: $code 0x9b60138
- 
  - label
  - 130
  - 2892
  - "            unless ($preserve->links($exam->find($G))) {"
  - 
    class: 0x9b60138oxble-4 013 0x9b60138
    id: 0x9b60138-4
    name: $code 0x9b60138
- 
  - label
  - 170
  - 2906
  - "                my $sum = summarise($G);"
  - 
    class: 0x9b60138oxble-5 013 0x9b60138
    id: 0x9b60138-5
    name: $code 0x9b60138
- 
  - label
  - 170
  - 2920
  - "                my @tup = $nameidcolor->($sum);"
  - 
    class: 0x9b60138oxble-6 013 0x9b60138
    id: 0x9b60138-6
    name: $code 0x9b60138
- 
  - label
  - 170
  - 2934
  - "                my $id = $tup[1];"
  - 
    class: 0x9b60138oxble-7 013 0x9b60138
    id: 0x9b60138-7
    name: $code 0x9b60138
- 
  - label
  - 170
  - 2948
  - "                push @removals, [\"remove\", $id ];"
  - 
    class: 0x9b60138oxble-8 013 0x9b60138
    id: 0x9b60138-8
    name: $code 0x9b60138
- 
  - label
  - 130
  - 2962
  - "            }"
  - 
    class: 0x9b60138oxble-9 013 0x9b60138
    id: 0x9b60138-9
    name: $code 0x9b60138
- 
  - label
  - 130
  - 2976
  - "            $G->unlink($svg);"
  - 
    class: 0x9b60138oxble-10 013 0x9b60138
    id: 0x9b60138-10
    name: $code 0x9b60138
- 
  - label
  - 90
  - 2990
  - "        });"
  - 
    class: 0x9b60138oxble-11 013 0x9b60138
    id: 0x9b60138-11
    name: $code 0x9b60138
- 
  - label
  - 50
  - 3004
  - "    }"
  - 
    class: 0x9b60138oxble-12 013 0x9b60138
    id: 0x9b60138-12
    name: $code 0x9b60138
- 
  - label
  - 50
  - 3018
  - "    "
  - 
    class: 0x9b60138oxble-13 013 0x9b60138
    id: 0x9b60138-13
    name: $code 0x9b60138
- 
  - boxen
  - 30
  - 3050
  - 18
  - 18
  - 
    class: 0x9b601d8oxble 01d 0x9b601d8
    fill: 01d
    id: 0x9b601d8
    name: $code 0x9b601d8
- 
  - label
  - 50
  - 3052
  - "    my $clear;"
  - 
    class: 0x9b601d8oxble-1 01d 0x9b601d8
    id: 0x9b601d8-1
    name: $code 0x9b601d8
- 
  - label
  - 50
  - 3066
  - "    unless ($viewed) {"
  - 
    class: 0x9b601d8oxble-2 01d 0x9b601d8
    id: 0x9b601d8-2
    name: $code 0x9b601d8
- 
  - label
  - 90
  - 3080
  - "        $clear = 1;"
  - 
    class: 0x9b601d8oxble-3 01d 0x9b601d8
    id: 0x9b601d8-3
    name: $code 0x9b601d8
- 
  - label
  - 50
  - 3094
  - "    }"
  - 
    class: 0x9b601d8oxble-4 01d 0x9b601d8
    id: 0x9b601d8-4
    name: $code 0x9b601d8
- 
  - label
  - 50
  - 3108
  - "    else {"
  - 
    class: 0x9b601d8oxble-5 01d 0x9b601d8
    id: 0x9b601d8-5
    name: $code 0x9b601d8
- 
  - label
  - 90
  - 3122
  - "        $viewed->DESTROY(); # can't translate() twice so trash it"
  - 
    class: 0x9b601d8oxble-6 01d 0x9b601d8
    id: 0x9b601d8-6
    name: $code 0x9b601d8
- 
  - label
  - 90
  - 3136
  - "        $viewed_node->unlink($us);"
  - 
    class: 0x9b601d8oxble-7 01d 0x9b601d8
    id: 0x9b601d8-7
    name: $code 0x9b601d8
- 
  - label
  - 50
  - 3150
  - "    }"
  - 
    class: 0x9b601d8oxble-8 01d 0x9b601d8
    id: 0x9b601d8-8
    name: $code 0x9b601d8
- 
  - boxen
  - 30
  - 3182
  - 18
  - 18
  - 
    class: 0x9b600b8oxble 00b 0x9b600b8
    fill: 00b
    id: 0x9b600b8
    name: $code 0x9b600b8
- 
  - label
  - 50
  - 3184
  - "    @drawings = (@removals, @animations, @drawings, draw_findable($self));"
  - 
    class: 0x9b600b8oxble-1 00b 0x9b600b8
    id: 0x9b600b8-1
    name: $code 0x9b600b8
- 
  - boxen
  - 30
  - 3216
  - 18
  - 18
  - 
    class: 0x9b60248oxble 024 0x9b60248
    fill: '024'
    id: 0x9b60248
    name: $code 0x9b60248
- 
  - label
  - 50
  - 3218
  - "    # join together the class=\"etc etc etc\" setting"
  - 
    class: 0x9b60248oxble-1 024 0x9b60248
    id: 0x9b60248-1
    name: $code 0x9b60248
- 
  - label
  - 50
  - 3232
  - "    map { ref $_->[-1] eq \"HASH\" && ref $_->[-1]->{class} eq \"ARRAY\" && do {"
  - 
    class: 0x9b60248oxble-2 024 0x9b60248
    id: 0x9b60248-2
    name: $code 0x9b60248
- 
  - label
  - 90
  - 3246
  - "        $_->[-1]->{class} = join \" \", @{ delete $_->[-1]->{class} }"
  - 
    class: 0x9b60248oxble-3 024 0x9b60248
    id: 0x9b60248-3
    name: $code 0x9b60248
- 
  - label
  - 50
  - 3260
  - "    } } @drawings;"
  - 
    class: 0x9b60248oxble-4 024 0x9b60248
    id: 0x9b60248-4
    name: $code 0x9b60248
- 
  - boxen
  - 30
  - 3292
  - 18
  - 18
  - 
    class: 0x9b602a8oxble 02a 0x9b602a8
    fill: 02a
    id: 0x9b602a8
    name: $code 0x9b602a8
- 
  - label
  - 50
  - 3294
  - "    my $status = \"For \". summarise($object);"
  - 
    class: 0x9b602a8oxble-1 02a 0x9b602a8
    id: 0x9b602a8-1
    name: $code 0x9b602a8
- 
  - label
  - 50
  - 3308
  - "    unshift @drawings, "
  - 
    class: 0x9b602a8oxble-2 02a 0x9b602a8
    id: 0x9b602a8-2
    name: $code 0x9b602a8
- 
  - label
  - 90
  - 3322
  - "        [\"status\", $status];"
  - 
    class: 0x9b602a8oxble-3 02a 0x9b602a8
    id: 0x9b602a8-3
    name: $code 0x9b602a8
- 
  - label
  - 50
  - 3336
  - "    unshift @drawings, [\"clear\"] if $clear;"
  - 
    class: 0x9b602a8oxble-4 02a 0x9b602a8
    id: 0x9b602a8-4
    name: $code 0x9b602a8
- 
  - label
  - 50
  - 3350
  - "    $self->drawings(@drawings);"
  - 
    class: 0x9b602a8oxble-5 02a 0x9b602a8
    id: 0x9b602a8-5
    name: $code 0x9b602a8
- 
  - boxen
  - 1392
  - 60
  - 30
  - 30
  - 
    fill: eac
    id: 0x9aceac8
    name: Node 0x9aceac8
- 
  - label
  - '1060.5'
  - 60
  - N(webbery) Graph filesystem (0x9aceac8)
  - 
    id: 0x9aceac8
- 
  - boxen
  - 1392
  - 100
  - 30
  - 30
  - 
    fill: 737
    id: 0x9ad7378
    name: Node 0x9ad7378
- 
  - label
  - 865
  - 100
  - N(filesystem) /home/steve/Music/The Human Instinct (0x9ad7378)
  - 
    id: 0x9ad7378
- 
  - boxen
  - 1392
  - 140
  - 30
  - 30
  - 
    fill: 130
    id: 0x9ac1300
    name: Node 0x9ac1300
- 
  - label
  - 1086
  - 140
  - N(webbery) Graph webbery (0x9ac1300)
  - 
    id: 0x9ac1300
- 
  - boxen
  - 1392
  - 180
  - 30
  - 30
  - 
    fill: 3c9
    id: 0x9b63c98
    name: Node 0x9b63c98
- 
  - label
  - 1103
  - 180
  - N(webbery) Graph codes (0x9b63c98)
  - 
    id: 0x9b63c98
- 
  - boxen
  - 1392
  - 220
  - 30
  - 30
  - 
    fill: 3a4
    id: 0x9b03a40
    name: Node 0x9b03a40
- 
  - label
  - '1094.5'
  - 220
  - N(codes) sub get_object (0x9b03a40)
  - 
    id: 0x9b03a40
- 
  - boxen
  - 1392
  - 260
  - 30
  - 30
  - 
    fill: c5f
    id: 0x9b5c5f8
    name: Node 0x9b5c5f8
- 
  - label
  - 1137
  - 260
  - N(webbery) clients (0x9b5c5f8)
  - 
    id: 0x9b5c5f8

#}}}
    ($expected, $got) = swap_svg_instruction_ids($expected, $got);
    $DB::single = 1;
    is_deeply($expected, $got, "yeah!");

};

sub swap_svg_instruction_ids {
    my ($expected, $got) = @_;

    use File::Slurp;
    write_file "gots.instro", $got;

    my @elines = split "\n", $expected;
    my @glines = split "\n", $got;

    my %exchanges;
    my $i;
    my $swap = sub {
        my ($what, $for, $i) = @_;
        $for =~ s/^'|'$//gs;
        $exchanges{$what} ||= $for;
        die "change!?!?! ($what -> $for != $exchanges{$what}) \n$elines[$i]\n$glines[$i]"
            unless $exchanges{$what} eq $for;
    };

    for $i (0..@elines-1) {
        $_ = $elines[$i];

        if (/class: .+ (\S{3}) /) {
            my $id = $1;
            $glines[$i] =~ s/(class: .+ )(\S{3}) /$1$id /;
            $swap->($2, $id, $i);
        }
        if (/fill: ('?\S{3}'?)/) {
            my $id = $1;
            $glines[$i] =~ s/(fill: )('?\S{3}'?)/$1$id/;
            $swap->($2, $id, $i);
        }
        if (/(0x\S{7}(oxble.*)?)/) {
            my $id = $1;
            $glines[$i] =~ s/(0x\S{7}(oxble.*)?)/$id/;
            $swap->($1, $id, $i);
        }
        $glines[$i] =~ s/ y=\d+$//;
    }
    (\@elines, \@glines);
}


