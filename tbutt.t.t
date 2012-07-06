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
- 
  - boxen
  - 10
  - 58
  - 18
  - 18
  - 
- 
  - label
  - 30
  - 60
  - 
    font-weight: bold
- 
  - boxen
  - 30
  - 78
  - 18
  - 18
  - 
- 
  - label
  - 50
  - 80
  - "    my ($codes, $section) = @_;"
  - 
- 
  - label
  - 50
  - 94
  - "    my @code = read_file('butter.pl');"
  - 
- 
  - label
  - 50
  - 108
  - "    $codes = $codes->spawn($section);"
  - 
- 
  - boxen
  - 30
  - 140
  - 18
  - 18
  - 
- 
  - label
  - 50
  - 142
  - "    while ($_ = shift @code) {"
  - 
- 
  - label
  - 90
  - 156
  - "        next until /^\\Q$section\\E/;"
  - 
- 
  - label
  - 90
  - 170
  - "        my $chunk;"
  - 
- 
  - label
  - 90
  - 184
  - "        $_ = \" \";"
  - 
- 
  - label
  - 90
  - 198
  - "        until (/^\\S/) {"
  - 
- 
  - label
  - 130
  - 212
  - "            $chunk .= $_ = shift @code;"
  - 
- 
  - label
  - 130
  - 226
  - "            if (/^\\s*$/sm && $chunk =~ /\\S/) {"
  - 
- 
  - label
  - 170
  - 240
  - "                $codes->spawn({ code => $chunk });"
  - 
- 
  - label
  - 170
  - 254
  - "                $chunk = \"\";"
  - 
- 
  - label
  - 170
  - 268
  - "                shift @code until $code[0] =~ /\\S/;"
  - 
- 
  - label
  - 130
  - 282
  - "            }"
  - 
- 
  - label
  - 90
  - 296
  - "        }"
  - 
- 
  - label
  - 90
  - 310
  - "        if ($chunk =~ /\\S/) {"
  - 
- 
  - label
  - 130
  - 324
  - "            $chunk =~ s/\\};?\\s*\\Z//xsm;"
  - 
- 
  - label
  - 130
  - 338
  - "            $codes->spawn({ code => $chunk });"
  - 
- 
  - label
  - 90
  - 352
  - "        }"
  - 
- 
  - label
  - 50
  - 366
  - "    }"
  - 
- 
  - boxen
  - 30
  - 398
  - 18
  - 18
  - 
- 
  - label
  - 50
  - 400
  - "    my $chunk_i = 0;"
  - 
- 
  - label
  - 50
  - 414
  - "    travel($codes, sub {"
  - 
- 
  - label
  - 90
  - 428
  - "        my ($chunk) = @_;"
  - 
- 
  - label
  - 90
  - 442
  - "        $chunk->thing->{i} = $chunk_i++;"
  - 
- 
  - label
  - 50
  - 456
  - "    });"
  - 
- 
  - boxen
  - 30
  - 488
  - 18
  - 18
  - 
- 
  - label
  - 50
  - 490
  - "    return $codes;"
  - 
- 
  - label
  - 10
  - 504
  - "} # }}"
  - 
- 
  - boxen
  - 1392
  - 60
  - 30
  - 30
  - 
- 
  - label
  - '1060.5'
  - 60
  - 
- 
  - boxen
  - 1392
  - 100
  - 30
  - 30
  - 
- 
  - label
  - 865
  - 100
  - 
- 
  - boxen
  - 1392
  - 140
  - 30
  - 30
  - 
- 
  - label
  - 1086
  - 140
  - 
- 
  - boxen
  - 1392
  - 180
  - 30
  - 30
  - 
- 
  - label
  - 1103
  - 180
  - 
- 
  - boxen
  - 1392
  - 220
  - 30
  - 30
  - 
- 
  - label
  - '1094.5'
  - 220
  - 
- 
  - boxen
  - 1392
  - 260
  - 30
  - 30
  - 
- 
  - label
  - 1137
  - 260
  - 

#}}}
    ($expected, $got) = swap_svg_instruction_ids($expected, $got);
    is_deeply($expected, $got, "yeah!")
        || makediff($expected, $got);

};

sub makediff {
    my ($expected, $got) = @_;
    use File::Slurp;
    write_file "gots.instro", join "\n", @$got;
    write_file "expe.instro", join "\n", @$expected;
    `diff gots.instro expe.instro > diff.instro`;
}

sub swap_svg_instruction_ids {
    my ($expected, $got) = @_;

    use File::Slurp;
    write_file "gots.instro", $got;

    my @elines = split "\n", $expected;
    my @glines = split "\n", $got;
    @elines = grep {
        ! (
            /class: .+ (\S{3}) /
         || /fill: ('?\S{3}'?)/
         || /(0x\S{7}(oxble.*)?)/
         )
        } @elines;
    @glines = grep {
        ! (
            /class: .+ (\S{3}) /
         || /fill: ('?\S{3}'?)/
         || /(0x\S{7}(oxble.*)?)/
         )
        } @glines;
    (\@elines, \@glines);
}


