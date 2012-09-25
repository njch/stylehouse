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

my $tests = new Graph;

my $case_1 = $tests->spawn("case 1");
run_case($case_1);

sub run_case {
    my $case = shift;
    
    my $expect  = load_expected($case);

    my $id = $main::whereto->[1]->{id};
    say "ID: $id";
    my $mojo = moje($id);
    hello($mojo);
    $main::us->spawn(1427)->id("width");
    get_object($mojo);
    use Storable 'dclone';

    my $got = dclone $drawings;

    diff_instructions($expect, dclone $got);

    if (prompt_yN) {
        save_expected($case, $got);
    }
}

sub diff_instructions {
    my ($expect, $got) = @_;
    # diff got <> expected, into a two column graph if diff
    # so the svger needs to know about columns, just a x offset initially
    my $results = new Graph();
    my $notok = $results->spawn("#notok");
    my $extra = $results->spawn("#extra");
    my $i = 0;
    my $what_for = {};
    for my $e_in (@$expect) {
        my $g_in = $got->[$i];

        copy_instructions_uuids($what_for, $e_in, $g_in);

        my $ginode = $results->spawn($g_in);
        unless (is_deeply($e_in, $g_in, "an instruction")) {
            $ginode->link($notok, $e_in);
        }
        $i++;
    }
    while (exists $got->[$i]) {
        ok(0, "got extra instruction");
        $extra->link($got->[$i]);
        $i++;
    }

    say displow($extra);
}
sub copy_instructions_uuids {
    my ($what_for, $from, $to) = @_;
    return unless $from->[0] =~ /boxen|label/;
    my $af = $from->[-1];
    my $at = $to->[-1];
    my $swapped = sub {
        my ($for, $what, $fo) = @_;
        say "Swapped $what -> $fo";
        if (my $for_before = $what_for->{$what}) {
            is ($fo, $for_before, "swapped like before $what $fo in %$af");
        }
        else {
            $what_for->{$what} = $fo
        }
    };
    use YAML::Syck;
    say Dump[$af, $at];
    for my $for (qw{fill stroke name id class}) {
        if ($at->{$for} && $af->{$for}) {
            $DB::single = 1;

            if (my ($for3) = $af->{$for} =~ /\W([0-9a-f]{3})\W/) {
                if ($at->{$for} =~ s/(\W?)([0-9a-f]{3})(?![0-9a-f]{9})(\W?)/$1$for3$3/g) {
                    $swapped->($for, $2, $for3);
                }
            }

            if (my ($for12) = $af->{$for} =~ /\W([0-9a-f]{12})\W/) {
                if ($at->{$for} =~ s/(\W?)([0-9a-f]{12})(\W?)/$1$for12$3/g) {
                    $swapped->($for, $2, $for12);
                }
            }

            $DB::single = !is_deeply($at, $af);
            say ".";
        }
    }
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
do {
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


