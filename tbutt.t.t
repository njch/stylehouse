use strict;
use warnings;
use Scriptalicious;
use Test::More 'no_plan';
use YAML::Syck;
use Storable 'dclone';
use List::MoreUtils;
start_timer();
require_ok 'butter.pl';
diag "required ".show_delta();
our $TEST = 1;
our $client;
do { # {{{
my $g1 = new Graph("test1");
my $g1n1 = $g1->spawn({color => "yellow"});
my $g1n2 = $g1->spawn({color => "red"});
$g1n1->link($g1n2);

sub disploww {
    my $got = displow(shift);
    $got =~ s/ [[:xdigit:]]{12}$//sgm;
    return $got;
}

is(disploww($g1n1)."\n", <<"", "displows");
N(test1) {"color":"yellow"}
 N(test1) {"color":"red"}

for (qw{red red red red orange vermillion}) {
    my $n = $g1n2->spawn({color => $_});
    /orange/ && $n->link($g1n1);
}

is(disploww($g1n1)."\n", <<"", "displows");
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
sub id {
    my $self = shift;
    $self->{param}->{id} = shift;
}
sub render {};
sub svg {
    return main::procure_svg();
}
sub sttus { shift; $main::sttus = [@_]; }
sub drawings { shift; $main::drawings = [@_]; }
package main;
sub new_moje {
    $sttus = undef;
    $drawings = undef;
    my $mojo = NonMojo->new();
    hello($mojo);
    $main::client->spawn(1427)->id("width");
} # }}}

my $tests = new Graph('tests');
my $cases = $tests->spawn("#cases");

`rm testrun/*.yml` if glob "testrun/*.yml";

do { # UNIT_EY
    my $case = $cases->spawn("unit test 1");
    local $TEST = $case;
    diag "BEGIN $case->{thing}";
#    my $expected  = load_expected($case);
    my $mojo = new_moje();

    my $themess = my $mess = new Graph("TheMess");
    for (qw{del rigo ringo john paul delwhert}) {
        my $s = $mess->spawn($_);
        length($_) % 2 && do { $mess = $s };
    }

    my $exammess = sub {
        my $s = $client->spawn(search(
            start => $mess,
            spec => '**',
            want => "G(object-examination)",
        ));
        $s->id("object-examination");
        return $s;
    };

    diag "test sub find_latest_examination"; #{{{
    my $todo = sub { find_latest_examination(undef, $mojo, $client) };

    ok(!defined($todo->()), "no last exam");

    my $twas = $exammess->();
    ok($todo->(), "got last exam");
    is($todo->(), $twas, "got last exam");

    my $twas2 = $exammess->();
    my $twas3 = $exammess->();
    my $twas4 = $exammess->();
    is($todo->(), $twas4, "got last exam");
    $twas3->link($client, "etc");
    is($todo->(), $twas4, "got last exam");
    is("object-examination4", $todo->()->thing->{name}, "named object-examination4");
    $twas3->thing->{name} = 'object-examination4';
    $twas4->thing->{name} = 'object-examination3';
    is($todo->(), $twas3, "lied about name - got lied back to");
#}}}

    diag "test sub examinate_graph"; #{{{
    $todo = sub { examinate_graph(shift || $themess) };
    my $ge = $todo->();
    ok($ge && ref $ge eq "Node", "got a Node");
    is($ge->links, 6, "six links");
    isnt($ge->{graph}, $themess->{uuid}, "separate Graph");
    my $rigo = ($ge->linked)[1];
    is($rigo->{graph}, $ge->{graph}, "node and node in graph");
    is($rigo->{thing}->{graph}, $themess->{uuid}, "inner node in other graph");
    is_deeply([map { $_->{thing}->{thing} } ($ge->linked)[1,2,3]],
        [qw'rigo ringo john'], "a bunch");
    
    my $eeg = $todo->($ge->graph);
    ok($eeg && ref $eeg eq "Node", "got a Node");
    is($eeg->links, 7, "six links");
    is(($eeg->linked)[0]->graph, $eeg->graph, "graph here");
    is(($eeg->linked)[0]->thing->graph, $ge->graph, "graph there");
    is(($eeg->linked)[3]->thing->graph, $ge->graph, "graph there");
    is(($eeg->linked)[0]->thing->thing, "Graph exam", "graph buck stops");
    is(($eeg->linked)[1]->thing->thing->graph, $themess, "graph beyond");

    say displow($eeg);
    is_deeply([uniq(map { $_->{0} } $eeg->links)], [$eeg], "they they they");
    my $john = ($eeg->linked)[4];
    is($john->{thing}->{thing}->{thing}, "john", "John!");
#}}}
};

exit;




my $case_1 = $cases->spawn("case 1");
run_case($case_1);

my $webbery = $main::findable->linked("G(webbery)")->thing;
my $webgraph = examinate_graph($webbery);


my $case_2 = $cases->spawn("case 2");
$case_2->spawn("#steps");
$case_2->spawn("#steps")->spawn("#id")->{thing} = sub {
    $main::client->linked("#width")->{uuid};
};
# make drawings

run_case($case_2);


sub run_case {
    my $case = shift;

    local $TEST = $case;
    
    my $expected  = load_expected($case);

    my @steps = goof($case, "+ #steps");

    say @steps." steps";
    my $mojo = new_moje();

    my $si = 1;
    for my $s (@steps) {
        local $TEST = $s;
        say "Case $case->{thing} step ".$si++;
        my $id = $s->linked("#id") || do {
            ($main::findable->linked("G(codes)"))[0]->thing->first->{uuid}
        };
        $id = $id->thing->() if ref $id eq "Node";
        say "ID: $id";
        $mojo->id($id);

        get_object($mojo);
    }

    my $last_step = ($case->linked("#steps"))[-1];
    my $last_drawings = $last_step->linked("#drawings");
    my $drawdata = $last_drawings->thing;

    my $ok = 1;
    for my $t (qw'drawings animations removals') {
        my $got = $drawdata->{$t};
        my $expected = $expected->{$t};
        my $datagraph = $last_step->spawn("#$t");

        unless (diff_instructions($datagraph, $expected, dclone $got)) {
            $ok = 0;
            say "Was a $t";
        }
    }
    if (0 && !$ok && prompt_yN("update expectations?")) {
        save_expected($case, $drawdata);
    }
    # TODO search up a new graph to dump out
    DumpFile('testrun/'.$case->{thing}.'.yml', $tests);
}
sub diff_instructions {
    my ($datagraph, $expect, $got) = @_;
    # diff got <> expected, into a two column graph if diff
    # so the svger needs to know about columns, just a x offset initially
    my $ok = 1;
    my $i = 0;
    my $what_for = {};
    for my $e_in (@$expect) {
        my $g_in = $got->[$i];
        my $d = { got => $g_in, expected => $e_in };
        $d = $datagraph->spawn($d);

        unless ($g_in) {
            $ok = 0;
            goof( $d, "+ #notok" );
            fail("got no instruction");
            next;
        }

        next if $e_in->[3] && $e_in->[3] =~ /^\S+ ids/;

        copy_instructions_uuids($what_for, $e_in, $g_in);

        my $diag = "an instruction of $g_in->[0]"
                .($g_in->[0] eq "label" ? ": $g_in->[-2]" : "");
        unless (is_deeply($g_in, $e_in, $diag)) {
            $ok = 0;
            goof( $d, "+ #notok" );
        }
        $i++;
    }
    while (exists $got->[$i]) {
        $ok = 0;
        goof($datagraph->spawn({ got => $got->[$i] }), "+ #notok");
        fail("got extra instruction");
        $i++;
    }
    return $ok;
}
sub copy_instructions_uuids {
    my ($what_for, $from, $to) = @_;
    return unless $from->[0] =~ /boxen|label|status/;
    my $af = $from->[-1];
    my $at = $to->[-1];
    if ($from->[0] !~ /clear|status/ && $to->[0] !~ /clear|status/) {
        for my $for (qw{fill stroke name id class}) {
            if ($at->{$for} && $af->{$for}) {
                $at->{$for} = idswapchunk($what_for, $af->{$for}, $at->{$for});
            }
        }
    }
    if ($from->[0] eq "label") {
        $to->[3] = idswapchunk($what_for, $from->[3], $to->[3]);
    }
    if ($from->[0] eq "status") {
        $to->[1] = idswapchunk($what_for, $from->[1], $to->[1]);
    }
}
sub idswapchunk {
    my ($what_for, $from, $to) = @_;

    use List::MoreUtils 'natatime', 'zip';
    my @fcs = split /(?<=\S) (?=\S)/, $from;
    my @tcs = split /(?<=\S) (?=\S)/, $to;
    my @ftcs = zip @fcs, @tcs;
    my $ch = natatime 2, @ftcs;

    my @tdone;
    while (my ($f, $t) = $ch->()) {
        my $long = $f =~ /\W?([0-9a-f]{12})\W?/ ? 12 : 3;
        if ($f =~ /(?:000)?\W?([0-9a-f]{$long})\W?/ && $1 ne "000") {
            my $new = $1;
            $t =~ s/(\W?)([0-9a-f]{$long})(\W?)/$1$new$3/g;
            my $old = $2;
            $f =~ /^000/ && $t =~ s/^.../000/;
    
            if (my $for_before = $what_for->{$old}) {
                unless ($new eq $for_before) {
                    fail("swapped like before $old -> $new");
                }
            }
            else {
                $what_for->{$old} = $new
            }
        }
        push @tdone, $t;
    }
    return join " ", @tdone;
}
    
sub load_expected {
    my $case = shift;
    my $case_name = $case->thing;
    my $expected_file = "testdata/$case_name/expected.yml";
    return LoadFile($expected_file) if -f $expected_file;
}
sub save_expected {
    my $case = shift;
    my $expected = shift;
    my $case_name = $case->thing;
    my $dir = "testdata/$case_name";
    mkdir $dir unless -d $dir;
    my $expected_file = "$dir/expected.yml";
    DumpFile($expected_file, $expected);
}

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
            /class: .+ /
         || /fill: ('?\S{3}'?)/
         || /(0x\S{7}(oxble.*)?)/
         )
        } @elines;
    @glines = grep {
        ! (
            /class: .+ /
         || /fill: ('?\S{3}'?)/
         || /(0x\S{7}(oxble.*)?)/
         )
        } @glines;
    (\@elines, \@glines);
}


