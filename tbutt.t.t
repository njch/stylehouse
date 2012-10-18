#!/usr/bin/perl
# copyright Steve Craig 2012
use strict;
use warnings;
use Scriptalicious;
use Test::More 'no_plan';
use YAML::Syck;
use Storable 'dclone';
use Scalar::Util 'weaken', 'isweak';
use List::MoreUtils;
start_timer();
require_ok('butter.pl')
    || die $@;
diag "required ".show_delta();
our $TEST = 1;
our $client;
our $webbery;
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
    return main::rocure_svg();
}
sub sttus { shift; $main::sttus = [@_]; }
sub drawings { shift; $main::drawings = [@_]; }
package main;
sub new_moje {
    $sttus = undef;
    $drawings = undef;
    my $mojo = NonMojo->new();
    if ($_[0]) { # TODO do we ever want to do this?
        $webbery = shift;
        my $clients = $webbery->find("#clients");
        my @clients = $clients->linked;
        @clients != 1 && die "oh no!";
        $main::client = shift @clients;
        $main::client->spawn("#trail");
        $client->spawn({})->id("#translates");
        $client->spawn("#svg");
    }
    else {
        hello($mojo);
        $main::client->spawn(1427)->id("width");
    }
    return $mojo
} # }}}

my $tests = new Graph('tests');
my $cases = $tests->spawn("#cases");

`rm testrun/*.yml` if glob "testrun/*.yml";

do { # UNIT_EY
} if 1;

sub dump_svg_linkage { # {{{
    my ($svg, @exams) = @_;
    my $vals_per_exam = svgvals($svg, @exams);
    my @exam_ks = keys %$vals_per_exam;
    my %seen_uuids;
    my $dump = sub {
        my $s = Dump(shift);
        $s =~ s/([0-9a-f]{12}-\w)\d/$1/g;
        return $s
    };
    my $vump = sub {
        return Dump [ map { encode_json($_) } @{ $_[0] }  ]
    };
    my $by_who = {};
    while (my ($uuid, $vals) = each %{ $vals_per_exam->{$exam_ks[0]} }) {
        my $o = object_by_uuid($uuid);
        my $eo = $exams[0]->find($o);
        my $who = $eo->thing->thing;
        my $by = $by_who->{$who} = {};
        $by->{$exam_ks[0]} = $vals_per_exam->{$exam_ks[0]}->{$uuid};

        if ($vals_per_exam->{$exam_ks[1]}->{$uuid}) {
            $by->{$exam_ks[1]} = $vals_per_exam->{$exam_ks[1]}->{$uuid};
        }
        $seen_uuids{$uuid} = 1;
    }
    while (my ($uuid, $vals) = each %{ $vals_per_exam->{$exam_ks[1]} }) {
        next if $seen_uuids{$uuid};

        my $o = object_by_uuid($uuid);
        my $eo = $exams[1]->find($o);
        my $who = $eo->thing->thing;
        my $by = $by_who->{$who} = {};
        $by->{$exam_ks[1]} = $vals_per_exam->{$exam_ks[1]}->{$uuid};
    }
    return $by_who;
}
sub svgvals {
    my ($svg, @exams) = @_;
    my %svgvals;
    for my $e (@exams) {
        my %obs_vals;
        travel($e, sub {
            my $G = shift;
            for ($svg->links($G)) {
                my $uuid = $G->thing->{uuid};
                push @{ $obs_vals{$uuid} ||= [] }, @{$_->{val}};
            }
        });
        $svgvals{$e->name} = \%obs_vals;
    }
    return \%svgvals;
} # }}}

sub check_folks_svg { # {{{
    my ($exam, $svg, $who, $uuid, $whoreally, $iduncs, $randomly) = @_;
    my $who_node = object_by_uuid($uuid);
    is($who_node->thing, ($whoreally ? $whoreally->() : "$who"),
        "$who found $who node");

    my @nonlinks = $svg->links($who_node);
    is(scalar(@nonlinks), 0, "$who svg doesn't link $who node");

    my $who_exam = $exam->find($who_node);
    is($who_exam->thing, $who_node, "$who found $who in exam");
    my @links = $svg->links($who_exam);
    my $howmany = 3;
    $howmany = 4 if $who eq '$code';
    is(scalar(@links), $howmany, "$who svg does link to $who exam node");
    is_deeply(
        [ uniq(map { $_->{0} } @links) ],
        [ $svg ],
        "$who all links from svg",
    );
    is_deeply(
        [ uniq(map { $_->{1} } @links) ],
        [ $who_exam ],
        "$who all links to $who exam",
    );
    my @vals = map { ${ $_->{val} }[0] } @links;
    my %whats;
    my @linesofcode;
    for my $v (@vals) {
        my $name = $v->[0] eq "boxen" ? "boxen ".$v->[3]."x".$v->[4] : "label";
        $whats{$name} = $v;
        if ($who eq '$code' && $v->[0] eq "label") {
            push @linesofcode, $v;
        }
    }
    my ($uuid_3) = $uuid =~ /(...)$/;
    $iduncs ||= "";
    $iduncs = "" if $who eq '$code';

    my $collap = sub {
        my ($h, @ids) = @_;
        return join(";", map { !defined($_) ? '~undef~' : $_ } @{$h}{@ids});
    };
    ok(my $b = $whats{"boxen 18x18"}, "$who boxen 18x18");
    is($collap->($b->[-1], qw'class id name fill stroke'),
        join(";", "$uuid_3 $uuid", "$uuid-b$iduncs", "$who $uuid", "$uuid_3", '~undef~'),
        "attributes");
    ok($b = $whats{"boxen 4x18"}, "$who boxen 4x18");
    is($collap->($b->[-1], qw'class id name fill stroke'),
        join(";", "$uuid_3 $uuid", "$uuid-c$iduncs", "$who $uuid", "000$uuid_3", "000"),
        "attributes");

    ok($b = $whats{"label"}, "$who label");
    if ($who eq '$code') {
        $b = $linesofcode[0];
        is($linesofcode[0]->[3],
            '    my $exam8 = $exam;',
            '  line of code 1');
        is($linesofcode[0]->[-1]->{id}, "$uuid-l", "    id");
        is($linesofcode[1]->[3],
            '    $_->unlink($exam) for $self, $client;',
            '  line of code 2');
        is($linesofcode[1]->[-1]->{id}, "$uuid-l2", "    id");
    }
    else {
        like($b->[3], qr/^N\(TheMess\) $who $uuid/, "  text");
    }
    is($collap->($b->[-1], qw'class id name'),
        join(";", "$uuid_3 $uuid", "$uuid-l$iduncs", "$who $uuid"),
        "attributes");

    if ($randomly) {
        $randomly->($who_exam, @vals);
    }
} #}}}

sub ss {
    my @nodes = @_;
    return scalar(@nodes);
}


my $i = 0;
until (++$i > 5) {
    if ($i == 1) {
        my $case = $cases->spawn("unit test 1");
        local $TEST = $case;
        diag "BEGIN $case->{thing}";
#    my $expected  = load_expected($case);
        my $mojo = new_moje();

        my $themess = my $mess = new Graph("TheMess");
        my @messfolk = qw{del rigo ringo john paul delwhert};
        for (@messfolk) {
            my $s = $mess->spawn($_);
            length($_) % 2 && do { $mess = $s };
        }

        my $exammess = sub {
            my $s = $client->spawn(search(
                start => $mess,
                spec => '**',
                want => "G(object-examination)",
                ($_[0] ? (traveller => $_[0]) : ()),
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

        is_deeply([uniq(map { $_->{0} } $eeg->links)], [$eeg], "they they they");
        my $john = ($eeg->linked)[4];
        is($john->{thing}->{thing}->{thing}, "john", "John!");
#}}}

        diag "test sub garbage_collect_examinations"; #{{{
        my @ob_exams = $client->linked("#object-examination");
        is scalar(@ob_exams), 4, "lots of old #object-examination";
        $todo = sub { garbage_collect_examinations(undef, $mojo, $client) };
        $todo->();
        my @ob_exams_now = $client->linked("#object-examination");
        is scalar(@ob_exams_now), 1, "only one now";
        is ($client->linked("#object-examination"), $twas3, "correct one remains");
        $client->link($ob_exams[1]);

        my @ob_exams_again = $client->linked("#object-examination");
        is scalar(@ob_exams_again), 2, "linked another";
        is ($client->linked("#object-examination"), $twas3, "scalar ->linked... could be either though; not ordered");

        $todo->();
        my @ob_exams_again_again = $client->linked("#object-examination");
        is scalar(@ob_exams_again_again), 1, "only one now";
        is ($client->linked("#object-examination"), $twas3, "correct one remains");

        my $twas5 = $exammess->();
        my @ob_exams_again_again_again = $client->linked("#object-examination");
        is scalar(@ob_exams_again_again_again), 2, "two now";
        $todo->();
        my @ob_exams_aaggaaiinn = $client->linked("#object-examination");
        is scalar(@ob_exams_aaggaaiinn), 1, "only one now";
        is $ob_exams_aaggaaiinn[0], $twas5, "correct one remains";
#}}}

        diag "test sub make_traveller"; #{{{ TODO pointless nowish?
        my $self = $client->spawn("#get_objection");
        make_traveller($self, $mojo, $client);
        my $trav = $self->linked("#traveller")->thing;
        ok(defined $trav && ref $trav eq "Travel", "got Travel");

        my $em = $exammess->();
        my $emeg = examinate_graph($em->thing);
        my @gots = map { $_->{thing}->{thing}->{thing} } $emeg->linked;
        is(@gots, 6, "got all without traveller");
        
        my $em2 = $exammess->($trav);
        my $emeg2 = examinate_graph($em2->thing);
        my @gots2 = map { $_->{thing}->{thing}->{thing} } $emeg2->linked;
        is(@gots2, 6, "got all-2 with traveller ignoring things");
        is($gots2[-1], 'delwhert', "the datum");

        ok($self->linked("#traveller"), "here");
        $self->unlink($self->linked("#traveller"));
        ok(!$self->linked("#traveller"), "gone");
#}}}

        diag "test sub search_about_object"; #{{{
        $self->spawn($mess)->id("#object");
        make_traveller($self, $mojo, $client);
        my $exam = search_about_object($self, $mojo, $client);
        ok defined $exam && ref $exam eq "Graph", "is a Graph!";
        is $exam->{name}, "object-examination8", "Graph with a name";
        is $exam->first->thing->graph->{name}, "TheMess", "contains nodes from TheMess graph";
        my @data = map { join(',', split /N\(object-examination8\) N\(TheMess\) /) }
            grep { s/ .{12}$// }
            split /\n/, displow($exam->first);
        is(join(";", @data), ',ringo; ,del;  ,rigo; ,john; ,paul; ,delwhert', "dumps correctly");

        is $client->linked("G(object-examination8)")->thing->{name}, 'object-examination8',
            "linked via client";
        is $self->linked("G(object-examination8)")->thing->{name}, 'object-examination8',
            "linked via self";
        is $self->linked("#object-examination")->thing->{name}, 'object-examination8',
            "linked via self with id";

#}}}

        diag "test sub generate_svg"; #{{{

        my @svgn = $client->linked("#svg")->links();
        is(scalar(@svgn), 1, "no #svg linkage");
        generate_svg($self, $mojo, $client);
        my $svg = $client->linked("#svg");
        like(summarise($svg), qr/^N\(webbery\) svg svg [0-9a-f]{12}$/, "got #svg node");
        my @svgp = $svg->links();
        is(scalar(@svgp), 7, "some #svg linkage");
        is($svgp[0]->{1}->{id}, "client", "linkage 0 == client");
        is_deeply($svgp[1]->{val}->[0], {x => 0, y => 0}, "linkage 1 == 0,0");
        is_deeply($svgp[2]->{val}->[0], {x => 1, y => 1}, "linkage 2 == 1,1");
        is_deeply($svgp[3]->{val}->[0], {x => 2, y => 2}, "linkage 3 == 2,2");
        is_deeply($svgp[4]->{val}->[0], {x => 1, y => 3}, "linkage 4 == 1,3");
        my @examsvgs = grep /N\(object-examination/,
            split "\n", displow($svg);
        my %messfolk = map { $_ => 0 } @messfolk;
        is_deeply([   grep { $_ !~ /^ N\(object-examination8\) N\(TheMess\) (\w+) [0-9a-f]{12}$/
                        || do { die "no $1" unless defined $messfolk{$1}; $messfolk{$1}++; 0 } } @examsvgs
            ], [],
            "svg graph nodes look good"
        );
        ok(!(grep { $_ ne 1 } values %messfolk), "svg graph nodes accounted for")
            || diag Dump(\%messfolk);

        my @folks = uniq(map { /TheMess\) (\w+ [0-9a-f]{12})$/ } @examsvgs);

        is($exam->name, "object-examination8", "have the object-exam");

#        diff_svg($self, $mojo, $client);
#        fill_in_svg(($self, $mojo, $client);


        # make another exam
        my $exam8 = $exam;
        undef $exam;
        $_->unlink('#object-examination') for $self, $client;
        $rigo = $themess->find("rigo");
        is($rigo->thing, "rigo", "rigo is rigo");
        my $codenode = $rigo->spawn( { code => <<''
    my $exam8 = $exam;
    $_->unlink($exam) for $self, $client;

            } );
        is(ref $codenode, "Node", 'codenode is node');
        is(ref $codenode->thing, "HASH", ' " thing is hash');

        my $exam9 = search_about_object($self, $mojo, $client);
        is($exam9->name, "object-examination9", "have the next object-exam");
        generate_svg($self, $mojo, $client);
        @examsvgs = grep /N\(object-examination9/,
            split "\n", displow($svg);
        %messfolk = map { $_ => 0 } @messfolk, '$code';
        is_deeply([   grep { $_ !~ /^ N\(object-examination9\) N\(TheMess\) (\$?\w+) [0-9a-f]{12}$/
                        || do { die unless defined $messfolk{$1}; $messfolk{$1}++; 0 } } @examsvgs
            ], [],
            "svg graph nodes look good"
        );
        @svgp = grep { $_->{1}->graph eq $exam9 } $svg->links();
        is(scalar(@svgp), 7, "some #svg linkage");
        is_deeply($svgp[0]->{val}->[0], {x => 0, y => 0}, "linkage 0 == 0,0");
        is_deeply($svgp[1]->{val}->[0], {x => 1, y => 1}, "linkage 1 == 1,1");
        is_deeply($svgp[2]->{val}->[0], {x => 2, y => 2}, "linkage 2 == 2,2");
        is_deeply($svgp[3]->{val}->[0], {x => 3, y => 3}, "linkage 3 == 3,3");
        ok(defined $svgp[3]->{1}->{thing}->{thing}->{code}, "linkage 3 is to code");
        is_deeply($svgp[4]->{val}->[0], {x => 1, y => 4}, "linkage 4 == 1,4");
        ok(!(grep { $_ ne 1 } values %messfolk), "svg graph nodes accounted for")
            || diag Dump(\%messfolk);
        @folks = uniq(map { /TheMess\) (\$?\w+ [0-9a-f]{12})$/ } @examsvgs);
#}}}

        diag "test sub diff_svgs"; #{{{
        my $i = 0;
        until (++$i > 2) {
            diag "BEGIN fork()";
            if (my $pid = fork()) {
                start_timer();
                wait();
                diag "END fork() (".show_delta().")";
            }
            else {
                if ($i == 1) {
                    diag "an svg diff"; # {{{
                    for (qw'drawings animations removals') {
                        $self->spawn([])->id($_);
                    }
                    for ($client->linked("#viewed")) {
                        $client->unlink($_);
                    }
                    $client->spawn($exam9)->id("#find");
                    $client->spawn($exam9)->id("#object-examination");
                    my $box8 = $client->spawn($exam8);
                    $client->spawn($box8)->id("#viewed");

                    diff_svgs($self, $mojo, $client);

                    my @anim_ls = $self->linked("#animations")->links;
                    shift @anim_ls; # get_objection
                    is(scalar(@anim_ls), 6, "all animate");

                    my @draw_ls = $self->linked("#drawings")->links;
                    shift @draw_ls; # get_objection
                    is(scalar(@draw_ls), 1, "one new drawing");

                    my @rem_ls = $self->linked("#removals")->links;
                    shift @rem_ls; # get_objection
                    is(scalar(@rem_ls), 0, "no removals");
# }}}
                }
                exit;
            }
        }
#}}}
        next;
    }

    diag "BEGIN fork()";
    if (my $pid = fork()) {
        start_timer();
        wait();
        diag "END fork() (".show_delta().")";
    }
    else {
        if ($i == 2) {
            diag "nothing";
            my $case_1 = $cases->spawn("case 1");
            run_case($case_1) unless "TODO"; # TODO regenerate that expectation
        }
        elsif ($i == 3) {
            diag "animation, removal"; # {{{
            my $case_2 = $cases->spawn("case 2");
            $TEST = $case_2;

            my $mojo = new_moje(
                load_graph_yml("testdata/case 2/webbery graph.yml")
            );
            is($webbery->name, "webbery", "webbery is webbery");
            my $svg = $webbery->find("#svg");
            my ($graphcode) = grep { $_->thing eq "sub graph_code" } $svg->linked;

            $case_2->spawn(sub {
                my $viewed = $case_2->linked("#viewed")->thing->thing;
                # TODO need this displow() call or viewed svg count will be only 3...
                # these dump the same
                #dump_graph_yml("bah", $webbery);
                displow($viewed);
                #dump_graph_yml("bah2", $webbery);
                my @viewed_svg;
                travel($viewed->first, sub {
                    my ($G, $ex) = @_;
                    return if $G->{thing}->{iggy};
                    push @viewed_svg, $svg->links($G);
                });
                is(scalar(@viewed_svg), 33, "viewed svg count");
            })->id("#viewed_hook");

            $case_2->spawn(sub {
                my $exam = $case_2->linked("#exam")->thing;
                my @exam_svg;
                travel($exam->first, sub {
                    my ($G, $ex) = @_;
                    return if $G->{thing}->{iggy};
                    push @exam_svg, $svg->links($G);
                });
                is(scalar(@exam_svg), 0, "pre-generate_svg exam svg count");
            })->id("#exam_hook");

            $case_2->spawn(sub {
                my $exam = $case_2->linked("#exam")->thing;
                my @exam_svg;
                travel($exam->first, sub {
                    my ($G, $ex) = @_;
                    return if $G->{thing}->{iggy};
                    push @exam_svg, $svg->links($G);
                });
                is(scalar(@exam_svg), 30, "post-generate_svg exam svg count");
            })->id("#svg_hook");


            get_object($mojo, $graphcode->{uuid});


            my $drawings = $case_2->linked("#drawings")->thing;
            my $clear = $case_2->linked("#clear");
            ok(!defined($clear), "no clear")
                || diag "clear says: ".join(": ", @{ $clear->thing });
            is($drawings->{id}, $graphcode->{uuid}, "id passed");


            is(scalar(@{$drawings->{drawings}}), 0, "0 drawings");
            is(scalar(@{$drawings->{removals}}), 1, "1 removal");
            is(scalar(@{$drawings->{animations}}), 30, "30 animations");

            for my $a (grep { $_->[1] =~ /^$graphcode->{uuid}/ } @{$drawings->{animations}}) {
                is($a->[2]->{svgTransform}, 'translate(-20 -20)', "first object moves up and to the left");
            }
            for my $a (grep { $_->[1] !~ /^$graphcode->{uuid}/ } @{$drawings->{animations}}) {
                is($a->[2]->{svgTransform}, 'translate(0 -20)', "other objects move up");
            }
# }}}
        }
        elsif ($i == 4) {
            diag "no";
            my $case_3 = $cases->spawn("case 3");
            $TEST = $case_3;

            my $mojo = new_moje(
                load_graph_yml("testdata/case 3/webbery graph.yml")
            );
            is($webbery->name, "webbery", "webbery is webbery");
            #my $codes = $webbery->find("codes");

            #is($codes->name, "codes", "codes");

            #get_object($mojo, $codes->{uuid});

            #dump_graph_yml('testrun/'.$case_3->{thing}.'.yml', $tests);
        }
        elsif ($i == 5) {
            diag "trash client"; #{{{
            my $case_3 = $cases->spawn("case 3");
            $TEST = $case_3;

            is(ss($webbery->find("#client")), 1, "0 #client initially");
            my $mojo = new_moje();
            is(ss($webbery->find("#client")), 1, "1 #client hello");
            hello($mojo);
            hello($mojo);
            hello($mojo);
            hello($mojo);
            is(ss($webbery->find("#svg")), 1, "1 svg still");
            is(ss($webbery->find("#client")), 1, "1 client still");
            is(ss($webbery->find("#translates")), 1, "1 translates still");
            hello($mojo);
            hello($mojo);
            is(ss($webbery->find("#clients")), 1, "1 clients still");
            is(ss($webbery->find("#clients")->linked), 1, "1 clients still");
            #say displow($mojo);
            is(ss($webbery->find("#svg")), 1, "1 svg still");
        } #}}}
        exit;
    }
}


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
            $webbery->find("#codes")->thing->first->{uuid}
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


