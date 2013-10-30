#!/usr/bin/perl
# copyright Steve Craig 2012
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
say "we are $0";

=head1 O

just a test harness?

and DONT FORGET TO TAKE GUITAR BREAKS

=head1 ETC

I saw the talk about our terrible tools hindering the chance of anything
good being made. maybe I will get some nicer tools soon.

I need to make the jump to pulling pools of perl together like goops in
an environment where my creations are mostly data and fractures of data
architecture, only occasional hacks on the underlying atomic structure.

taxonomic inspiration: each knowledge thing we can reason to about any
$_ is a field - as in a field of knowledge, opposite end to the unified
field where everything becomes the same, applying fields is increasing
entropy.

the machinery is made of itself asap. we shall call this singularity X.

Post-X must be rules about what can react, creation of new fields.


Next time is about discerning shapes and levels of behaviour and trying
to hallucinate visual representation for them and how that would work.
need to research animated datastructure toolkits... (like they exist)

God damn those lumps of my intellect before they're broken down into
perly contrivances are exactly the thing to cater for. it's all just
flowing datastructures. rhythm is the new thing I will be doing, since
it's so important to Doing The Right Thing.

the problem is I became an artist. now I know that my ideas are
expressions. it is too hard to express them with the material available.
lower the barrier for entry, but more importantly shorten the marathon
of invention, always trying to beat apathy.

I'd love a command & conquer like map of code, instead of being a huge
text file. swampy bits could be shrank up relative to important bits.

=head1 ALGORITHMS

data flows through algorithms

an algorithm is a bunch of machine-thinking-ideas graph
 which can be the unit of testability
 testable means the nature of what's inside can be experimented upon
 to optimise it and the surrounding program

all the algorithms are just graphs, into which complexity can be injected.
like passing a closure but without making code exponentially ugly.

so at a point of the program there could be yay many algorithms working together like so
with some complicated by some need to work together just so
it's a tangle of machines and thinking and ideas layered on top of each other graphically

probably we would find that the pattern of node linkage was always very simple
and could be simulated behind link() etc API with something faster

streaming algorithms that can make shortcuts for big datasets
and resources with timing etc realities

the question is how to express this in graph so it scales...
nodes could store links on themselves if it made sense...
all these slight tweaks in nature "if it makes sense" are obviously coming from
the world of graph self-analysis and optimisation...
firstly we should break the /object code into functions which feed each other..
or the getlinks() code, why not...
the variables' light cone allows the shape of the algorithm around it to change.
inputs and outputs, chains of them

=cut

=head1 FIELDS

We're using different Graph objects to get a field effect... a complete set
of links without neighbour noise

we should be able to say this part of the graph is now a field...
if an algorithm is entropied by the limit of the field, this is shown
    as a bulge or something, somewhere
links to within from outside and vice versa should be seen
field secretiveness (relative to anything?)
so is creating a field over nodes cloning them? with backlinking?
perhaps you create the selection first then say clone
perhaps something can slither out of the way, of course it can...

So there's usually just one graph per App
App would branch away its various data but it's one bunch of links
a perl program in this new world would be more like a daemon serving
the illusion of several Apps and whatever they need, down to the existing tech

but floatilla of algorithms and junk

each node in the subset could be linked to the original in secret way
(if a query asked it could traverse back into the original graph)
once we have subsets carved out we can run them into algorithms easier

there's kind of a turf concept going on... various customs for travellers...

now we're using IDs to find things in closed circuits of links...

=cut

=head1 HMM

so like protein coders that want to survive, the base apparition creates a
luxurious overworld

"if it lives, it lives" is the base statistical point to life, humanity and its
complexity is just increasing luxury erupting on top

I believe I am sewing mental dischord sometimes but I am working it okay

entropy can't be explained, the teacher will go off on tangent after tangent,
while the student gets more and more full of unresolving notionettes.

head1 THIRD

linkery can be on each object or in the fields link store
revelation 1 is links-on-objects.
r1 is to get a graph of the codey rules leading to r2
r1 holds objects to represent itself in an extensible manner

for any function there's a physical medium/machinery for data flow and action
on top of that something says "this is this kind of idea and why"
and the idea itself is applied to the machinery it will effect

machinery (for data flow)
thinking (on the machinery)
ideas (what stuff is for)

so ideas need to cosy up to machinery real nicely, thinking could get complicated adapting things
(had gone on a tangent here) so through their shared ideas (and/or via thinking) different machinery can work together.
there might be an ambient idea realiser (optimisation ideas...) in r2 pattern matching...
like how ideas look for reality to improve on

concurrent graph pattern matching needed...
pattern matching means a chunk of graph exists, for example execution is at this point about this kind of machinery/data/etc...

argumentative language is machinery, which invokes ideas through fractured thinking.

so we needa take data to make machines to make thinking and ideas and more graph computer complexity.

machine says take this data, munge it like so, put it here.

there's a machine around the machine, the execution environ, where data is looked for and dumped out.
in this environ there's arms and eyeballs protruding in on the swarming machines.

hmm like ideas get more beautifully meaningful-per-word, the rig of r2 dangles increasingly greasey code down to perl

trying to see the shape of things where code becomes machine! ah long lost reality.

At Field Hutt Josh says "massive chunks" and my being ignites, salivating... We're dogs with jobs.

on search: the result graph is result nodes containing the matched thing...
IT IS DETERMINED somewhere before execution of the receiving function whether that thing wants the result node or the thing
this situation can be SEEN, because it's all graph all the time.
the resolve could be thinking, machine-generated in test cases.

test cases should be a major part of generating the program as well as proving it.
say "take [a,b,c]s and {etc}". etc code has sanity checks mixed in with function and either. like /(.+) etc/ || die

so what does r2 want to do?
pattern matches to:
    notice where/when/what we are and mess with things accordingly
        each of these messings creates a mess, in theory, but it's better to have messy theory and clean practice since you can't see theory.
        mostly we shall just load up the graph technology itself with little complications. that graph generates code that we hop over to.

so r1 allows the graph tech to be loaded up with complications and then that generates r2 graph tech code.
r2 graph tech supports all the sweet functionality.
r2 graph computer? what decides what gets executed? well for development, tests and web client requests will do...

the r2 graph computer is just another machine that gets executed.
    I wonder if it implements the thinking-idea relative strangeness or that stuff could be r1 complicated
    it could perhaps not be required for some initial r2 functionality?
    perhaps it is a mistake to avoid putting things in r1? what shape is r1 really?
    if there's anything to do it can get done first hand
        the point of separating machine-thinking-idea is to clarify the engineering and also open possibilities of computer understanding
    the graph computer is an ambient dude that waits for the world to get to it?
    aha no yeah its state wants to be seen by things wanting to do things at certain points of computation

anyway we will say we want to run this machine here -> "lastfm submit scrobbler.log"
and it executes its machine pulls in other machines through ideas etc etc.
ah so a machine graph can specify specific other machines too somehow, if it can locate them somehow...
you could also say NO, not that machine, this machine, for it is an alike idea, but adapt the input/output data flow with this machine, etc.


can I turn my typing-letters-in-order skills into a profitable business? no, probably just a bizarre bunch of material (art?)

the interface is for capturing material to compute and impressing the user.

=head1 SO

a lexical scope, adapted into a graph function, is a sorta field
inherited variables are adapted with thinking...

it's feeling more musical for further along this cut.

keeping time with a six minute track on loop.

making testery for graph, represented as ui drawing instructions.
that stuff will eventually be runnable/always run and visible in the ui.
twould be good to have ui in one process and fork for tests.
run another perl process altogether and get output?
get output how? database time? nah.
fuck that, just ui runnable test routines would be the ticket.
then those routines could elabourate into machine clusterations
the tests are the routines right.

- limber up graph happening.
thawed graph bootstraps itself with links from nowhere to all its nodes.
usually there'd be links from at least somewhere philosophical to everything
talking about it relative to various formulas

there's definitely that machine-thinking-ideas pattern awaiting elegant apparition.

=head1 TODO

need to get whole svg state from test script back to the scope, so it can be seen
should probably rejig the ui a bit now it's more stable to support...
- breadcrumb history
- yadda
- dump depth limiting
- exceptions to said
- those exceptions a kind of view port
- view ports
- view ports by graph pattern like G(webbery)/filesystem
- tests run from ui
- butter hacks managed in butter ui itself
- to deploy a new butter ui the new process requests to the old process to die
- leaving it necessary state to keep on truckin

seeing things happening:
 lets make the get_object:
   make drawing cats: drawings animations removals
   gen, diff, fillin svg
   collecting them things and clearing, statusing...
 should be able to see these things happening in graph...
 see the execution of get_object at all points
 resume in there and interrogate data


the scope is for navigating through dimensions and aspects of program being

code becomes code graph
 - artistic code structure abstractions like shrinking vast uglies
 - diagram/maps of code
 - invent: click link in browser, gvim goes to the line of code

gvim still hacks up text file, changes migrated into code graph
 - needs to be visual if it's tricky or if user wants to
 - this could stretch right down to git
 - the whole user's interaction is an evolving tree of actions

avoid changing line numbers

insert break/dump points, run code as another entity

need to have each sub log somewhere what it does

then we have this huge shape of the program's execution
 - look for patterns

these patterns involve some data nature and some program nature

we can look for places where svg gets linked to anything
one butter creates another butter for increasing experiment
like an intellectual caterpillar slipping into the future

so we need to automatically hack hooks into butter and execute it

the hooks note whats happening back to the past
hopefully the program can be re-executed and happen exactly the same
so we can go up to a point and hit pause
simple

entropy field == light cone for data?
with total functional entropy figured by watching execution of test cases
hmm indeed

queries are middle managers.
if the top boss works infinitely fast as computers do he can deal with everything.

an invention:
render shapes at random, endeavouring genetically using human to point out bits
that look like this or that
build with that a visual vocabulary
use that to generate a noisy field that could be interpreted by four square orientations
into four sequences of a comic
all this kind of formulaicism
if you see the images in different order is your brain effectively prepared differently

looking at the screen vs not.
may be something to experiment with.

summarise and this little thing growing in note() are a case of data massage
from one set into a string various ways, pulling out extra bits of info
or recursing deeper in, always with some limitation
seems like the kind of thing to take care of easily somehow

it's all about massaging data

click click

make a tool for capturing the path from one point in the graph to another

make a tool for drawing links

get_object turns into a dispatcher

make them dispatch tables/graphs for get_object so we can start hacking on it fast

get_object will get the object of stylehouse in to being

life works through its means

structures for structures. perhaps it wuld be more playful and fun and maybe even faster
to build something for sheer graph gaming, then distill a stylehouse from what's possible
to imitate in there. probably just an insightful exercise...

we are all stylehouses. get to the point of freedom of expression where you're just applying styles.
it's not the end, it's just the stylehouse. what then.



=head1 FOURTH

we want to find patterns in the notation:
 everything under a certain call becomes a map
 apply the map to another certain call, if things are relatively the same then alright!
that would take a lot of coding but not much user clicking around time

code need tons of intellect put into it or it can be more open to the user's intellect

=head2 COMPLICATIONS

do_stuff() takes a $P-rogram graph limb, calls mach hooked in there

they can mess with the nature of what calls them
messing with the caller is hacked in right now cause what calls them isn't graphy algorithm yet

eventually the complication would be an algorithm complete with how to mess with the caller,
etc etc. and of course sanity/test cases...

so eventually there'd be a whole lot of things complicating the Graph/Node infrastructure
until its nature is juicy enough to do everything we want to do with it

tempting to say it would rewrite itself in perl with less hooking...
its actions would have to be able to be in $E if bug chasing got down to it
tracking calls beyond eg getlinks() is a waste of time, except for sometimes maybe

it's a computer mind that can be forked, tested and suddenly begin real work on real data

a lot of short term complications will be, for doing stuff through time, like later_id_remover()
which is where making things algorithms can make things more semantically simple
cause then they can be stretched out through time with obviousness

=head2 REAL DATA

some user input etc. should be saved into yaml datasheets.

=head2 ANYWAY

the $P graph is a table of contents for the program

hacks are expressed as machs attached to the $P graph

the $E graph is execution state/history
 a call stack down to a point
 pointers to dead graph etc.
 a way to pause, fork, change, resume continuously as a sexy debugging process

I suppose within the $E flow will be various entropy-related forces of execution

also the $U graph, stuff the user is doing?

lets make the code for complications faster, caching them into perl data from graph masters
then get on with USING complixity to enhance enhance etc

trippyboxen needs config saving abilities
which involves finding paths into the code to various numbers

need a way to graph code such that the user can click on things to give meaning
  so code becomes lines
  lines become bits
  alterations attach to bits
  meaning attaches also to bits
    meanings create thinking to ideas, and we have an algorithm
    make another algorithm that connects them algorithms
need these meaning mappings to break upon refactoring
meaning can then be mapped into a meaningful UI for eg synth playing

make get_object use transparent not-graph stuff for its algorithming...
encapsulate the algorithm as a light cone entropy field whatever
the code shines lights through the API, through time, it's about connecting those beams

from the forray of graphing codes...
  codes() gets data,
  short_codegraph() chews it up a bit for #thecodegraph,
  #codegraph_ancode digs out the actual code back from G(codes)
probably lets...
  user wires meaning into the codes
  user fucks with frankenbutter codes
  frankenbutter behaviour observed
  behaviour mapped to fuckery
like saving synth operations
programs synthesise data

also lets...
  define some datatypes eg a node, perl code, a list or a search() result for svgering
  so while experimenting we can just chuck things out to the scope
G(scope):
    "toolbar" -> elements
    "exam" -> elements
  where the elements are scope data objects (connected with layout sensibilities)
  we complicate unlinks in this graph to generate element removes
  things that want animation can complicate for it
  has begun but need to delete "exam" when it's no longer the object of attention...

expand upon #notation
so we can use it to watch frankenbutter tick
it's the beginning of the action/attention machine
to understand its own functioning
understand meaning to be able to present it to the developer so they can understand
it's a symbiosis of three:
 franken does stuff
 butter interprets notation
 developer sees patterns and applies the human mind

create some notation maps, known low-level trees to fold up
    and some big-deals to draw bigger, eg Web->run, get_object requests
  see frankenbutter execution
    add resume/breakpoints
      control via notation()
      run webserver while broken?
    interrogate franken being via port 3001 from butter

console.log when a remove or animate doesn't find its target

make field membership a hash in the node for fast association (and use it so)

the linguotic web of program
the attention that shines on patches of structure
the actions that build graph

so features complicate "public" program bits until common ground is laterally established

WORDS
=cut

our $breaks = [];
if ($0 =~ /frankenbutter/ && -e "breaks.yml") {
    $breaks = LoadFile("breaks.yml");
}
elsif (-e "breaks.yml") {
    `rm breaks.yml`
}
our $note_line = 0;
our $port = "3000";
our $frankpid;

our $json = JSON::XS->new()->convert_blessed(1);
our $webbery = new Graph('webbery');
our $scope = new Graph('scope');
our $toolbar = new Graph('tools')->spawn('toolbar');
our $machs = $webbery->spawn("#mach");
our $client; # TODO low priority though is sessions
our $codes = codes();
our $G;
our $TEST;
use File::Slurp 'append_file';
`cat /dev/null > notation`;

our $P = do { # {{{
# TODO eventually everything beyond the r1 Graph/Node/main stuff will be built up here
# then Graph/link will not refer to r1 Graph/link but r2 Graph/link which is generated
#   by conplications in G(program), which is run on r1
    my $P = new Graph('program');
    for (qw{
        Graph/link/done
        Graph/unlink/deleted_link
        scope/changing_object
        get_object/ctrl
        get_object/01
        fill_in_svg/oaid
        }) {
        my @path = split '/';
        my $pathmake;
        $pathmake = sub {
            my ($from, @path) = @_;
            my $next = shift @path;
            my $already = ref $from eq "Graph" ? $from->find('#'.$next) : $from->linked('#'.$next);
            $from = $already || $from->spawn("#". $next);
            $pathmake->($from, @path) if @path;
        };
        $pathmake->($P, @path);
    }
    $P
};

sub sw33t {
    # nothing
}

sw33t();

my $todo_per_point_cache = {};
sub pointilise {
    my $point = shift;
    my @path = split '/', $point;
    my $next = shift @path;
    my $p = $P->find("#".$next);
    $p or die "no such $next";
    while (@path) {
        $next = shift @path;
        $p = $p->linked("#".$next);
        $p or die "no such $next";
    }
    return $p;
}
sub attach_stuff_until {
    my ($p, $untilp, $mach) = @_;
    attach_stuff($p, $mach);
    attach_tidyup($p, $untilp, $mach);
}
sub attach_tidyup {
    my ($p, $untilp, $mach) = @_;
    my $tidyup;
    $tidyup = mach_spawn("#".$mach->id."_tidyup", sub {
        detach_stuff($p, $mach);
        detach_stuff($untilp, $tidyup);
    });
    attach_stuff($untilp, $tidyup);
}
sub attach_stuff {
    my ($p, $mach) = @_;
    delete $todo_per_point_cache->{$p};
    my $point = pointilise($p);
    $point->link($mach);
    say "attached $mach->{id} to $p";
}
sub detach_stuff {
    my ($p, $mach) = @_;
    delete $todo_per_point_cache->{$p};
    my $point = pointilise($p);
    unless (ref $mach) {
        $mach = $machs->linked("$mach");
    }
    say "doing detach of $mach->{id} to $p";
    $point->unlink($mach);
}
sub do_stuff {
    my ($p, @a) = @_;
    unless ($P) {
        return
    };

    my $todo_cached = $todo_per_point_cache->{$p};
    my @machs;
    if (defined $todo_cached) {
        @machs = @$todo_cached;
    }
    else {
        my $point = pointilise($p);
        @machs = grep { $_->linked($machs) } $point->linked();
        $todo_per_point_cache->{$p} = [@machs];
    }

    my $plan = {};
    for my $m (@machs) {
#        say " running mach ". $m->id;
#        say "args @a";
        my $r = $m->thing->(@a);
        if (ref $r eq "HASH" && $r->{changeofplan}) {
            $plan = $r; # TODO multiplicity clobbered: geometry testing will make the haphazard okay
        }
        if (ref $r eq "HASH" && $r->{return}) {
            $plan = $r->{return}
        }
    }
    return $plan;
} # }}}


sub note { # {{{
    my $args = \@_;
    my @a;
    my $splash;
    my $sply;
    $sply = sub { # TODO refactor together the SOOMs
        my $t = shift;
        return '~undef~' if !defined $t;
        if (!ref $t) {
            $t =~ s/\n//;
            return "'$t'";
        }

        no warnings "experimental";

        given (ref $t) {
            when ("CODE") {
                return "CODE";
            }
            when (/Node|Graph|Travel/) {
                if ($t->{uuid}) {
                    return ref($t)."=$t->{uuid}"
                }
                else {
                    my $hash = $splash->($t) unless $_[0];
                    $hash ||= "%t";
                    return ref($t)." NO UUID: ".$hash
                }
            }
            when ("HASH") {
                return $splash->($t);
            }
            when ("ARRAY") {
                return '['.join(", ", map { $sply->($_) } @$t).']';
            }
            when (/Mojolicious::Controller/) {
                return 'Mojo'
            }
            when ("Regexp") {
                return "$t"
            }
            default {
                die "unknown ref: $t: ".ref $t;
            }
        }
        die" ";
    };
    $splash = sub {
        my $hr = shift;
        return "{ ".join(", ", map { $sply->($_, "noresplash") } %$hr)." }"
    };
    my $i = 0;
    while ((caller($i++))[0]) {}
    for (@$args) {
        push @a, $sply->($_);
    }
    my $ind = join "", (" ")x$i;
    append_file("notation", $ind. shift(@a)."\t". join(", ", @a) ."\n");

    my $line_was = $note_line;
    $note_line++;

    if (@$breaks && $line_was >= $breaks->[0]) {
        if ($line_was == $breaks->[0]) {
            say "for the first time at $line_was\n";
            $breaks->[1] = $i;
            break_dump(1);
        }
        elsif ($breaks->[1] && $i < $breaks->[1]) {
            say "and out at $line_was\n";
            break_dump(2);
            $breaks = [];
        }
    }
} # }}}

sub break_dump {
    my $n = shift;
    DumpFile("break_dump_$n", $P);
}

our %graphs; # {{{
package Graph;
use YAML::Syck;
use strict;
use warnings;
sub new {
    shift;

    my $self = bless {}, __PACKAGE__;
    $self->{name} = main::uniquify_id(\%main::graphs, shift || "unnamed");
    $self->{links} = [];
    $self->{nodes} = [];
    $main::graphs{$self->{name}} = $self;
    $self->{uuid} = main::make_uuid();
    main::reg_object_uuid($self);
    return $self
}
sub name {
    return $_[0]->{name};
}
sub link {
    my ($self, $I, $II, @val) = @_;
    $I = $self->spawn($I) unless ref $I eq "Node";
    $II = $self->spawn($II) unless ref $II eq "Node";
    my $l = {
        0 => $I, 1 => $II,
        val => [@val],
    };
    push @{$self->{links}}, $l;
    main::do_stuff('Graph/link/done', $self, $l);
}
sub unlink {
    my ($self, @to_unlink) = @_;
    Carp::confess 'nothing to unlink' unless @to_unlink;
    my %to_unlink;
    for (@to_unlink) {
        warn "different graphs.. ".
            main::summarise($_->{0}) ." vs ". main::summarise($_->{1})
            if ($_->{1}->{graph} ne $_->{0}->{graph}
                || $_->{1}->{graph} ne $self->{uuid})
                && !($_->{0}->id =~ /drawings|animations|removals/
                     || $_->{0}->thing && $_->{0}->thing eq "svg")
    }
    $to_unlink{$_->{_id} || "$_"} = undef for @to_unlink;
    my $links = $self->{links};
    for my $i (reverse 0..@$links-1) {
        if (exists $to_unlink{$links->[$i]}) {
            my $name = $links->[$i];
            my $l = splice @$links, $i, 1;
            delete $to_unlink{$name};
            main::do_stuff('Graph/unlink/deleted_link', $self, $l);
            return unless keys %to_unlink;
        }
    }

}
sub denode {
    my ($self, @to_denode) = @_;
    my %to_denode;
    for my $n (@to_denode) {
        $to_denode{$n} = $n;
    }
    my $nodes = $self->{nodes};
    for my $i (reverse 0..@$nodes-1) {
        if ($to_denode{$nodes->[$i]}) {
            my $gone = delete $to_denode{$nodes->[$i]};
            splice @$nodes, $i, 1;
        }
    }
    if (%to_denode) {
        my ($one) = values %to_denode;
        die "failed to delete node: ".Dump[
            map { main::summarise($_) } values %to_denode
        ];
    }
}
sub map_nodes {
    my ($self, $code) = @_;
    my @nodes = @{$self->{nodes}};
    for my $n (@nodes) {
        $code->($n);
    }
}
sub first {
    $_[0]->{nodes}->[0]
}
sub find {
    my ($self, $thing) = @_;
    my @nodes;
    $self->map_nodes(sub {
        if ($thing =~ /^#/ ? main::spec_comp($thing, $_[0])
             : defined $_[0]->{thing} && $_[0]->{thing} eq $thing) {
            push @nodes, $_[0];
        }
    });
    wantarray ? @nodes : shift @nodes;
}
sub spawn {
    my $self = shift;
    my $n = Node->new(
        graph => $self,
        thing => shift,
    );
    push @{$self->{nodes}}, $n; #TODO weaken? garbage collect?
    return $n;
}
sub trash_id {
    my $self = shift;
    my $id = shift;
    $_->trash for $self->find($id);
}
sub DESTROY {
    my $self = shift;
    say "DESTROY ".main::summarise($self);
    for my $l (@{$self->{links}}) {
        delete $l->{$_} for keys %$l;
    }
    undef $self->{links};
    undef $self->{nodes};
    delete $main::graphs{$self->{name}};
};
package Node;
use strict;
use warnings;
use List::MoreUtils 'uniq';

sub new { # graph => $graph,
    shift;
    my $self = bless {}, __PACKAGE__;
    my %params = @_;
    $self->{graph} = $params{graph}->{uuid};

    $self->{uuid} = main::make_uuid();
    main::reg_object_uuid($self);

    $self->{thing} = $params{thing};
    if ($self->{thing} && $self->{thing} =~ /^#/) {
        $self->id($self->{thing});
        undef $self->{thing};
    }

    return $self
}
sub TO_JSON {
    my $self = shift;
    return join "  ", "$self:", %$self
}
our $field;
sub spawn {
    my $self = shift;
    my $spawn = $self->graph->spawn(shift);
    $self->link($spawn, @_);
    $spawn->{field} = $field if $field;
    return $spawn;
}
sub in_field {
    my $self = shift;
    my $code = shift;
    $self->{field} = $field = $self->{field} ||= main::make_uuid();
    $code->($self);
    undef $field;
}
sub id {
    my $self = shift;
    if (my $id = shift) {
        $id =~ s/^#//;
        $self->{id} = $id;
    }
    return $self->{id};
}
sub trash {
    my $self = shift;
    my $field = shift;
    die $field if $field;
    if ($self->{field}) {
        my (@links, @nodes);
        main::travel($self, { forward_links => sub {
            my ($G, $ex, $ls) = @_;
            if ($G->{field} && $G->{field} eq $self->{field}) {
                $ex->{via_link}->{0} || return;
                ref $G eq "Node" || die "hur";
                die "field leaving graph at ".main::summarise($G)
                    if $G->{graph} ne $self->{graph};
                push @links, $ex->{via_link};
                push @nodes, $G;
            }
            else {
                push @links, $ex->{via_link};
                @$ls = ();
            }
        } });
        $self->graph->unlink(uniq @links) if @links;
        push @nodes, $self;
        $self->graph->denode(uniq @nodes) if @nodes;
    }
    else {
        for my $n ($self->linked) {
            #say main::summarise($self)." going to delete ".main::summarise($n);
            $self->unlink($n);
        }
        $self->graph->denode($self);
    }
}
sub graph {
    my $self = shift;
    until ($main::objects_by_id{$self->{graph}}) {
        say $self->{graph}." not existing";
        say $self ." (".$self->thing.") is looking for another graph to be in...";
        $self->{graph} = shift @{ $self->{other_graphs} || [] } || do {
            say "No other graphs"; return undef;
        };
        say "Found $self->{graph} called ".$main::objects_by_id{$self->{graph}}->{name};
    }
    return $main::objects_by_id{$self->{graph}}
}
sub another_graph {
    my $self = shift;
    my $other_graph = shift;
    my $ogs = $self->{other_graphs} ||= [];
    push @$ogs, $other_graph unless grep { $other_graph eq $_ } @$ogs;
}
sub link {
    $_[0]->graph->link(@_)
}
# TODO require node or link input
sub unlink {
    my ($self, @others) = @_;
    my @links;
    @others = grep { !(ref $_ eq "HASH" && $_->{0} && $_->{1}
                        && do { push @links, $_; 1 }) } @others;
    for my $o (@others) {
        for my $l ($self->links($o)) {
            push @links, $l
        }
    }
    if (@others && !@links) {
        Carp::cluck "not actually linked: ".main::Dump { main::summarise($self) => [ map { main::summarise($_) } @others ] };
        return;
    }
    $self->graph->unlink(@links)
}
sub linked {
    my ($self, $spec) = @_;
    my @linked = uniq map { $_->{1} } $self->links($spec);
    wantarray ? @linked : shift @linked;
}
# so also if ga n1 links to gb n2, n2 should find n1 somehow
sub links {
    my ($self, $spec) = @_;
    if (!$spec) {
        return main::getlinks(from => $self);
    }
    else {
        return main::search(
            start=> $self,
            spec => $spec,
            want => "links",
        );
    }
}
sub thing {
    $_[0]->{thing} || $_[0]->{id} || die "nothing in ". Dump $_[0];
}
package Travel;
use strict;
use warnings;
sub new {
    shift;
    my %p = @_;
    my $self = bless {}, __PACKAGE__;
    if ($p{ignore}) {
        $self->ignore(delete $p{ignore});
    }
    if (%p) {
        $self->{ex} = \%p;
    }
    return $self;
}
sub ignore {
    my $self = shift;
    push @{$self->{ignore}||=[]}, main::tup(shift);
}
sub travel {
    my $self = shift;
    $main::G = shift || $main::G;
    my $ex = $self->{ex} || {};
    if ($self->{ignore}) {
        my @ignores = map {
            /^->\{(.+)\}$/ ? do {
                my $k = $1;
                sub { ref $_[0]->{1} eq "Node"
                    && ref $_[0]->{1}->thing eq "HASH"
                    && $_[0]->{1}->thing->{$k} }
            } : /^nonref$/ ?
                sub {
                    ref $_[0]->{1} eq "Node" || return 0;
                    !ref $_[0]->{1}->thing }
              : /^(\w+)$/ ? do {
                my $w = $1;
                sub {
                    $_[0]->{1}->thing eq $w
                }
            } : /^#(.+)$/ ? do {
                my $id = $1;
                sub {
                    $_[0]->{1}->{id} && $_[0]->{1}->{id} eq $id
                }
            } :
            die "don't know how to ignore a $_"
        } main::tup($self->{ignore});
        my $anything_to_ignore = sub {
            my $l = shift;
            for (@ignores) {
                return 1 if $_->($l)
            }
            return 0
        };
        $ex->{new_links} = sub {
            my ($G, $ex, $l) = @_;
            @$l = grep { !$anything_to_ignore->($_) } @$l
        };
    }
    my %params = @_ == 1 ? (everywhere => $_[0]) : @_;
    while (my ($k, $v) = each %params) {
        if (exists $ex->{$k}) {
            $ex->{$k} = sub {
                $ex->{$k}->(@_);
                $v->(@_);
            };
        }
        else {
            $ex->{$k} = $v
        }
    }
    main::travel($main::G, $ex, main::summarise($main::G));
}
package main;
#}}}

sub mach_spawn { # {{{
    my ($id, $sub, @etc) = @_;
    $id =~ /^#?\w+$/ || die "bad id: $id";
    $id =~ s/^(?!#)/#/; # add a # if none (stored/returned by Node->id() without)
    my $m = $machs->spawn($id);
    $m->{thing} = $sub;
    if (shift @etc) {
        $toolbar->link($m);
    }
    if (@etc) {
        my ($spec) = @etc;
        my $for = delete $spec->{open_guts};
        $spec->{owner} = $m->id;
        # TODO in_field for all these machs so they go away on tidyup?
        #   or some more graphily robust mach-awakeness epicentre 
        # these sub-machs need to be attached and detached as the owner is requested or dequested
        my ($controls, $controller) = display_code_guts($for, %$spec);
        my $enabled = 0;
        mach_spawn("#".$spec->{owner}."_setup", sub {
            unless ($enabled) {
                attach_stuff("get_object/ctrl", $controller);
                attach_for_once('get_object/01', "#".$spec->{owner}."_tidyup", sub {
                    my ($self) = @_;
                    detach_stuff("get_object/ctrl", $controller);
                    $scope->trash_id("#".$spec->{owner}."_controls");
                    $enabled = 0;
                });
                $enabled = 1;
            }
        });
    }
    return $m
}
sub mach2_spawn {
    my ($id, $sub, @etc) = @_;
    $id =~ /^#?\w+$/ || die "bad id: $id";
    $id =~ s/^(?!#)/#/; # add a # if none (stored/returned by Node->id() without)
    my $m = $machs->spawn($id);
    $m->{thing} = $sub;
    my (@setup, @tidyup);
    while (@etc) {
        my $k = shift @etc;
        if ($k eq "toolbar") {
            $toolbar->link($m);
        }
        elsif ($k eq "controls") {
            my $spec = shift @etc;
            $spec->{owner} = $m->id;
            my ($controls, $controller) = make_controls(%$spec);

            push @setup, sub {
                attach_stuff("get_object/ctrl", $controller);
            };
            push @tidyup, sub {
                detach_stuff("get_object/ctrl", $controller);
                $scope->trash_id("#".$spec->{owner}."_controls");
            };
        }
        elsif ($k eq "vars") {
            my $vs = shift @etc;
            push @setup, sub {
                my $process = $client->linked("#".$m->id."_process");
                my $vars = $process->spawn("#vars");
                for my $v (@$vs) {
                    my ($name, $default) = %$v;
                    if (ref $default) {
                        $default = dclone $default;
                    }
                    $vars->spawn($default)->id("#".$name);

                }
            }
        }
    }

    my $enabled = 0;
    mach_spawn("#".$m->id."_setup", sub {
        unless ($enabled) {
            $client->spawn("#".$m->id."_process");
            $_->() for @setup;
            attach_for_once('get_object/01', "#".$m->id."_tidyup", sub {
                $_->() for @tidyup;
                $client->graph->trash_id("#".$m->id."_process");
                $enabled = 0;
            });
            $enabled = 1;
        }
    });

    return $m
}

attach_stuff("Graph/link/done", mach_spawn("#graph_interlinkage", sub {
    my ($g, $l) = @_;
    if ($l->{0}->graph ne $l->{1}->graph) {
        $l->{1}->another_graph($l->{0}->graph->{uuid});
    }
}));
attach_stuff("Graph/unlink/deleted_link", mach_spawn("#unlink_sanitycheck", sub {
    my ($g, $l) = @_;
    # TODO could check that $l intended at $n->unlink gets $g->unlinked (here)
    # TODO for that we'd need to look up the $E graph until we found the $P Node/unlink call
    # TODO this sub is doing nothing, it's sorta too late to check the sanity of the unlink
})); # }}}

mach_spawn("#filesystem", sub { # {{{
    my ($self, $mojo, $client) = @_;
    my $fs = new Graph ("filesystem"); 
    my $fs_head = $fs->spawn("/home/steve/Music/The Human Instinct");
    use File::Find;
    find(sub {
        return if $_ eq "." || $_ =~ /\/\.rockbox/;
        my $dir = $fs->find($File::Find::dir);
        $dir || die "no dir... $File::Find::dir";
        $dir->spawn($File::Find::name);
    }, $fs_head->thing);
    $fs->map_nodes(sub {
        my $G = shift;
        ($G->{thing}) = $G->{thing} =~ /\/([^\/]+)$/;
    });
    get_object($mojo, $fs->{uuid});
}); # }}}

mach_spawn("#thecodegraph", sub { # {{{
    my ($self, $mojo, $client, $id) = @_;

    if (!$id) {
        # rendering all codes
        my $short = $webbery->find("#codegraph");
        $short ||= $webbery->spawn(short_codegraph());
        $short->id("#codegraph");

        my $root = $short->thing->find("root");

        # so that the get_object graph has weird ids that will lead back to this mach
        my $oaid_munt = mach_spawn("#codegraph_munt_oaid", sub {
            my ($self, $new, $oaid) = @_;
            return {return => "cg_".$new->thing->{uuid}};
        });
        attach_stuff("fill_in_svg/oaid", $oaid_munt);
        get_object($mojo, $root->{uuid});
        # return to us though, this aint really an exam
        the_object($machs->linked("#thecodegraph"));
        attach_tidyup("fill_in_svg/oaid", "get_object/01", $oaid_munt);
    }
    else {
        # expanding a code
        $id =~ s/^cg_//;
        my $codenode;
        my $short = $webbery->find("#codegraph")->thing;
        $short->map_nodes(sub {
            $codenode = $_[0] if $_[0]->{uuid} eq $id});
        $codenode = object_by_uuid($codenode->thing->{origin});
        my $code = $codenode->thing->{code};

        my $y = 50;
        my @draws = ['clear'];
        for (split("\n", $code)) {
            my ($ws) = /^(\s+)/;
            push @draws, ['label', 10 + (5 * length($ws||"")), ($y += 20), $_ ]
        }
        $mojo->drawings(@draws);
    }
}, "toolbar"); # }}}

mach2_spawn("#notation", sub { # {{{ NOT
    my ($self, $mojo, $cliuent, $id) = @_;


    $machs->linked("#notation_setup")->thing->(); # should be outside of this sub?
    my $process = $client->linked("#notation_process") || die "no process ". Dump([$client->linked]);
    my $vars = $process->linked("#vars"); # like OO data
    my $lines = $vars->linked("#selected_lines")->thing;

    if ($id && $id =~ /_l(\d+)(etc)?$/) {
        my $line = $1;
        $lines->{$line} = undef;
        DumpFile("breaks.yml", [$line]);
        $machs->linked("#refrank")->thing->(undef, undef, undef, "nogodiggydie");
        $vars->spawn("1")->id("#break_dump");
    }
    elsif ($id && $id =~ /switcheroo_button$/) {
        my $bd = $vars->linked("#break_dump");
        $bd->{thing} = $bd->{thing} == 2 ? 1 : 2 if $bd;
    }

    my @notation = read_file('notation');
    my @elements = ['clear'];
    my $l = 0;

    # we select an entity in the tree
    # we restart frankenbutter with directions to go to that entity in the notation
    # ie. point in execution, and send us a report on something
    # then continue one step and send us another report
    # need more geometric graph pattern matching

    my $ind_limit = 5;
    my $row_limit = 60;
    my $page = $vars->linked("#page")->thing;
    my $from = 0;

    if ($page != 1) {
        $from = ($page - 1) * ($row_limit - 1);
    }
    say "page $page is $from away";

    my @notes;
    my $stupid;
    foreach (@notation) {
        my ($ind, $note) = /^(\s+)(.+)\n$/;
        unless (defined $ind) {
            $stupid = 1;
            next;
        }
        $ind = length($ind);

        push @notes, { l => $l++, note => $note, ind => $ind };
    }
    if ($stupid) {
        warn "unindented stuff left unparsed";
    }

    my @notes_collapsed; #{{{
    while (my $n = shift @notes) {
        my @this_row;
        while ($n && $n->{ind} >= $ind_limit) {
            push @this_row, $n;
            $n = shift @notes;
        }
        push @this_row, $n unless @this_row;
        if (@this_row > 1) {
            my $total = scalar(@this_row);
            my $first = shift @this_row;
            if (exists $lines->{$first->{l}}) {
                $_->{ind} += 2 for @this_row;
                unshift @this_row, $first;
            }
            else {
                my $etc = dclone $first;
                $etc->{note} = "etc $total";
                $etc->{ind} += 2;
                @this_row = ($first, $etc);
            }
        }
        push @notes_collapsed, @this_row;
    }
    @notes = @notes_collapsed;

    my @notes_paged;
    for (@notes) {
        next while --$from > 0;
        push @notes_paged, $_;
        if (@notes_paged >= $row_limit) {
            last;
        }
    }

    if (@notes_paged == 0 && $page > 1) {
        push @elements, ['status', "no page $page"];
    }
    @notes = @notes_paged;

    my ($x, $y) = (40, 40);
    my $make_note_element = sub {
        my $note = shift;
        my $l = $note->{l};
        my $ind = $note->{ind};
        $note = $note->{note};
        my ($pack, $sub) = $note =~ /'(\w+)::(\w+)'/;
        $pack ||= "etc";
        my $x = $x + $ind * 16;

        my $strokes = {
            main => "black",
            Graph => "#33ff44",
            Node => "red",
            etc => "#656565",
        };

        my $attr = {};
        $attr->{id} = "notation_l$l";
        $attr->{id} .= "etc" if $note =~ /^etc/;
        $attr->{fill} = "#gg9922";
        $attr->{fillOpacity} = "0.5";
        $attr->{stroke} = $strokes->{$pack} || "white";
        $attr->{strokeWidth} = 3;

        push @elements,
            ['boxen', $x, $y + 7, 6, 6, $attr],
            ['label', $x + 19, $y, $note, { id => $attr->{id}."l" }];

        $y += 12;
    }; #}}}

    $make_note_element->($_) for @notes;

    my $news = {}; # animatin {{{
    # must come first as translated boxen get rendered in the old place first
    for (@elements) {
        next unless $_->[0] eq "boxen";
        $news->{$_->[-1]->{id}} = [$_->[1], $_->[2]];
    }
    my @anim;
    if ($vars->linked("#olds")) {
        my $olds = $vars->linked("#olds")->thing;
        for (@elements) {
            next unless $_->[0] =~ /boxen|label/;
            my $old = $olds->{$_->[-1]->{id}};
            next unless $old;

            my $x = $_->[1] - $old->[0];
            my $y = $_->[2] - $old->[1];
            next if $x == 0 && $y == 0;

            say "gun animate $_->[-1]->{id}";

            push @anim, [
                "animate", $_->[-1]->{id},
                {svgTransform => "translate($x $y)"},
                500
            ];
            $_->[1] = $old->[0];
            $_->[2] = $old->[1];
        }
        $vars->linked("#olds")->trash();
    }
    $vars->spawn($news)->id("#olds");
    push @elements, @anim; #}}}

    $machs->linked("#notation_controls")->thing->();
    if ($vars->linked("#break_dump")) {
        my $bd = $vars->linked("#break_dump");
        my @dump = read_file("break_dump_".$bd->{thing});
        my ($x, $y) = (20, 800);
        for (@dump) {
            push @elements,
                ['label', $x, ($y += 20), $_ ]
        }
    }
    $mojo->drawings(@elements);

}, "toolbar",
controls => {
    elements => [
        ["page", "number", "up down"],
        ["switcheroo", "button"],
    ],
    y => 800,
    x => 20,
},
vars => [
    { "page" => 1 },
    { "selected_lines" => {} },
],
); # }}}

sub demagnetise_coord { # {{{ CONTI
    my ($axis, $val) = @_;
    if ($val >= 1) {
        return $val
    }
    my ($width) = $client->linked("#width")->thing;
    if ($val > 0 && $val < 1) {
        die "relative y" if $axis eq "y";
        return int($val * $width)
    }
    $val = $val * -1;
    die "relative y" if $axis eq "y";
    return $width - $val
}

sub make_controls {
    my (%p) = @_;

    my $owner_mach = $machs->linked('#'.$p{owner}) || die;
    my @bits = @{$p{elements}};

    my $controls = mach_spawn($p{owner}."_controls", sub {
        my $process = $client->linked("#".$p{owner}."_process")
            || die "no $p{owner} process in progress";

        my @controls;
        my $y = demagnetise_coord( y => $p{y} || 40 );
        my $x = demagnetise_coord( x => $p{x} || 20 );
        my $i = 0;
        for (@bits) {
            my ($target, $type, $etc) = @$_;
            # vaguely looks like the mach has become an object and here are the data
            my $vnode = $process->linked("#vars")->linked("#".$target);
            my $label = $target;
            my $id = $p{owner}."_ctrl_";

            if ($type eq "number") {
                $vnode || die;
                $label .= " ".$vnode->thing;
                $id .= $vnode->{uuid};
                my $b = -6;
                for (qw'up down') {
                    next unless $etc =~ /\b$_\b/;
                    push @controls,
                        ['boxen', $x, $y + $b + 8, 10, 6,
                        { fill => "f".(8 + $b / 2)."7", id => $id."_number_".$_ }];
                    $b += 7;
                }
                $x += 12
            }
            elsif ($type eq "button") {
                $id .= $target;
                push @controls,
                    ['boxen', $x, $y + 8, 18, 18,
                    { fill => "f".(8 / 2)."7", id => $id."_button" }];
            }

            if (/\S/) {
                push @controls, ['label', $x, $y, $label,
                    { id => $id."_l" },
                ]
            }
            $x += length($_) * 10;
            $i++;
        }
        $scope->trash_id("#$p{owner}_controls");
        my $ctrls = $scope->spawn("#$p{owner}_controls");
        $ctrls->spawn($_) for @controls;
        return ();
    });

    my $controller = mach_spawn($p{owner}."_controller", sub {
        my ($mojo, $id) = @_;
        my ($vuuid, $what, $how) = $id =~ /^$p{owner}_ctrl_(\w+?)_(\w+?)(?:_(\w+))?$/;

        return unless $vuuid && $what;
        my $vnode = object_by_uuid($vuuid);

        if ($what eq "number") {
            my $hows = {
                up => '+ 1', upup => '* 2',
                down => '- 1', downdown => '* 0.5',
            };
            my $v = $vnode->thing;
            eval "\$v = \$v $hows->{$how}";
            $vnode->{thing} = $v;
        }

        # run the thing we just hacked up. do we always want to?
        $owner_mach->thing->(undef, $mojo, undef, $id);
    });

    return ($controls, $controller);
} # }}}

sub display_code_guts { # {{{ GUTS
    my ($codename, %p) = @_;

    my $owner_mach = $machs->linked('#'.$p{owner}) || die;

    my ($package) = $codename =~ s/^(\w+):://;
    $package ||= "main";

    my $thecode;
    $codes->map_nodes(sub {
        my $n = shift;
        if ($n->thing->{sub} && $n->thing->{sub} eq $codename
            && $n->thing->{p} && $n->thing->{p} eq $package) {
            $thecode = $n->thing->{code};
        }
    });
    unless ($thecode) {
        die "cannot find ".$package."::".$codename;
    }
    my @tbc = split /\n/, $thecode;
    shift @tbc; # ... {
    pop @tbc;   # }

    my @head_tail;
    if ($p{from} || $p{to}) {
        my (@head, @tail);
        if ($p{from}) {
            push @head, shift @tbc until $tbc[0] =~ $p{from};
        }
        if ($p{to}) {
            push @tail, pop @tbc until $tbc[-1] =~ $p{to};
        }
        @head_tail = (join("\n", @head) || "", join("\n", reverse @tail) || "");
    }

    my @bits = split /(?=\s+|[\+\-\*\/\)\(]|\.\.)/, join "\n", @tbc;

    my $controls = mach_spawn($p{owner}."_controls", sub {
        my @controls;
        my $y = $p{y} || 40;
        my $x = 20;
        my $i = 0;
        for (@bits) {
            if (/\d+/ && $p{controls} =~ /numbercrankers/) {
                my $b = -12;
                for (qw'upup up down downdown') {
                    push @controls,
                        ['boxen', $x, $y + $b + 8, 10, 6,
                        { fill => "f".(8 + $b / 2)."7", id => $p{owner}."_ctrl_".$i."num_".$_ }];
                    $b += 7;
                }
                $x += 12
            }
            if ($_ eq "\n") {
                $x = 20;
                $y += 30;
            }
            if (/\S/) {
                push @controls, ['label', $x, $y, $_,
                    { id => $p{owner}."_ctrl_".$i."l" },
                ]
            }
            $x += length($_) * 10;
            $i++;
        }
        $scope->trash_id("#$p{owner}_controls");
        my $ctrls = $scope->spawn("#$p{owner}_controls");
        $ctrls->spawn($_) for @controls;
        return ();
    });

    my $controller = mach_spawn($p{owner}."_controller", sub {
        my ($mojo, $id) = @_;
        my ($i, $what, $how) = $id =~ /^$p{owner}_ctrl_(\d+)(\w+)_(\w+)$/;
        unless ($what && $how) {
            return
        }
        if ($what eq "num") {
            my $hows = {
                up => '+ 1', upup => '* 2',
                down => '- 1', downdown => '* 0.5',
            };
            $bits[$i] =~ s/(\d+)/eval "\$1 $hows->{$how}"/e;
        }

        my $new_code = join "", @bits;
        if (@head_tail) {
            $new_code = join "\n", $head_tail[0], $new_code, $head_tail[1];
        }

        my $new_sub;
        eval "\$new_sub = sub { $new_code } ";
        die Dump[$new_code, $@] if $@;

        if ($codename =~ /^mach (.+)$/) {
            my $mach = $machs->linked("#$1");
            $mach->{thing} = $new_sub;
        }
        else {
            my $glob = '*'.$package.'::'.$codename;
            eval "$glob = \$new_sub";
            die Dump[$new_code, $glob, $@] if $@;
        }

        # run the thing we just hacked up. do we always want to?
        $owner_mach->thing->(undef, $mojo);
    });

    return ($controls, $controller);
} # }}}

sub codes { # {{{
    my @code = read_file('butter.pl');
    my @chunks = ([]);

    while ($_ = shift @code) {
        if (0 && /^=head1/) {
            1 until shift(@code) =~ /^=cut/;
            next;
        }
        elsif (/^\S/ && !/^(use|our|#).+/) {
            unless (/^\}/) {
                push @chunks, [$_];
                next;
            }
        }

        push @{ $chunks[-1] }, $_;
    }
    my $codes = new Graph("codes");
    my $i = 0;
    my $p = "main";
    my @fb;
    for (map { join "", @$_ } @chunks) {
        my $code = $_;
        $p = $1 if /^package (\w+);/;
        my %etc;
        $etc{sub} = $1 if /^sub (\w+) {/;
        $etc{sub} = "mach $1" if /^(?:\S+.+)?mach_spawn\("#(\w+)", sub {/;

        $codes->spawn({
            code => $code,
            i => $i++,
            p => $p,
            %etc,
        });

        if ($etc{sub} && $etc{sub} !~ /note|DESTROY|summarise/) {
            my $notecode = "main::note('$p\:\:$etc{sub}', \@_);";
            $code =~ s/(sub (\w+ )?\{)/$1 $notecode/
                || die "faile $code";
        }
        push @fb, $code;
    }
    write_file("frankenbutter.pl", join "", @fb);
    return $codes;
}
sub short_codegraph {
    my $byp = {};
    my $short = Graph->new("shortcodegraph")->spawn("root");
    $codes->map_nodes(sub {
        my $n = shift;
        my $p = $byp->{$n->{thing}->{p}} ||= [];
        push @$p, $n;
    });
    while (my ($k, $v) = each %$byp) {
        my $p = $short->spawn($k);
        my @ns = sort { $a->{thing}->{i} <=> $b->{thing}->{i} } @$v;
        for my $n (@ns) {
            if ($n->{thing}->{sub}) {
                $p->spawn({
                    sub => $k."::".$n->{thing}->{sub},
                    origin => $n->{uuid},
                });
            }
        }
    }
    return $short->graph;
} # }}}

sub make_an_exit {
    exit;
}

if ($0 =~ /frankenbutter/) {
    $port = "3001";
    # start webbery on another port
    # fork for test routines
    # reload subroutines as butter hacks them up
}
else {
    frankenfork();
}
sub frankenfork {
    if ($frankpid = fork()) {
        # start our own webbery, talk to frankenbutter
    }
    else {
        say "  $$ exec'ing frankbutter.pl ...";
        exec "perl frankenbutter.pl";
    }
}

mach_spawn("#tbutt", sub { # {{{
    my ($self, $mojo, $client) = @_;

    start_timer();
    my ($rc, @output) = capture_err("perl", "tbutt.t.t", "harnessed");

    say "test run $rc with ".scalar(@output);
    my $run = $webbery->spawn("#testrun");
    $run->spawn(["return code", $rc]);
    $run->spawn(["time", show_delta()]);

    my $res = "parse error";
    for (reverse @output) {
        if (/# Looks like you failed (\d+) tests of (\d+)/) {
            $res = $2-$1." / $2";
            last;
        }
    }
    my ($ok, $notok, @blabs);
    push @blabs, { '...' => [] };
    for (@output) {
        if (/^ok (\d+)/) {
            $ok++
        }
        elsif (/^not ok (\d+)/) {
            $notok++
        }
# in each forked process the oks will reiterate
        if (my ($d) = /^# (.+)$/) {
            push @blabs, { $d => [] };
            if ($d =~ /BEGIN fork\(\)/) {
# start a branch
            }
            elsif ($d =~ /END fork\(\) \((.+)\)/) {
# finish a branch
            }
        }
        else {
            my $h = $blabs[-1];
            my ($a) = values %$h;
            push @$a, $_
        }
    }
    $run->spawn(["result", $res]);
    $run->spawn(["oks", $ok]);
    $run->spawn(["notoks", $notok]);
    $run->spawn(["diags", [map { keys %$_ } @blabs]]);


    get_object($mojo, $run->{uuid});
}, "toolbar"); # }}}

# {{{ the linkstash
our %objects_by_id;
use UUID;
use Scalar::Util 'weaken';
sub make_uuid {
    UUID::generate(my $uuid);
    UUID::unparse($uuid, my $stringuuid);
    $stringuuid =~ s/^.+-(.+?)$/$1/;
    return $stringuuid;
}
sub reg_object_uuid {
    my $o = shift;
    weaken $o;
    my $stringuuid = $o->{uuid} || die;
    $objects_by_id{$stringuuid} = $o;
}
sub object_by_uuid {
    my $id = shift;
    if (!exists $objects_by_id{$id}) {
        return undef;
    }
    elsif (!defined $objects_by_id{$id}) {
        # weak link  garbage collected
        delete $objects_by_id{$id};
        return undef;
    }
    else {
        return $objects_by_id{$id}
    }
}
sub dump_graph_yml {
    my ($file, $graph) = @_;
    my $first = $graph;
    my $graphs = { $graph->{uuid} => $graph };
    my $yaml;
    my $loop = 1;
    while ($loop) {
        $loop = 0;
        $yaml = Dump([ $first, values %$graphs ]);
        while ($yaml =~ /graph: ([0-9a-f]{12})/g) {
            $graphs->{$1} ||= do {
                $loop = 1;
                object_by_uuid($1);
            };
        }
    }
    write_file($file, $yaml);
    say "wrote $file";
}
sub load_graph_yml { #LOAD
    my $file = shift;
    my $graphs = LoadFile($file);
    for my $graph (@$graphs) {
        $objects_by_id{$graph->{uuid}} = $graph;
    }
    for my $graph (@$graphs) {
        travel($graph, sub {
            my ($G) = shift;
            my $id = $G->{uuid};
            if (ref $G eq "Graph") {
                if (exists $main::graphs{$G->{name}}) {
                    warn "already got a graph named $G->{name}!"
                        unless $TEST;
                }
                $main::graphs{$G->{name}} = $G;
            }
            if (exists $objects_by_id{$id}) {
                die "Dump restore clang:".
                    Dump [$G, $objects_by_id{$id}]
                        if "$G" ne "$objects_by_id{$id}";
            }
            $objects_by_id{$id} = $G;
        });
    }
    return wantarray ? @$graphs : $graphs->[0]
}

sub search { # TODO {{{
    my %p = @_;
    $p{start} || confess "where?";
    if ($p{want} && $p{want} eq "links") {
        return getlinks(from => $p{start}, to => $p{spec});
    }
    elsif ($p{want} && $p{want} =~ /^G\((\S+)\)$/) {
        my $graph_name = $1;
        my $res = new Graph($graph_name);
        my $trav = $p{traveller} || Travel->new(
            ($p{ignore} ? (ignore => $p{ignore}) : ())
        );
        my %tps = ( everywhere => sub {
            my ($G, $ex) = @_;
            if ($ex->{previous}) {
                my $found = $res->find($ex->{previous});
                $found->spawn($G, $ex->{via_link});
            }
            else {
                $res->spawn($G);
            }
        } );
        for (qw'forward_links') {
            $tps{$_} = $p{$_} if defined $p{$_};
        }
        $trav->travel($p{start}, %tps);
        return $res;
    }

}
sub getlinks {
    my %p = @_;

    my @links;
    if ($p{to} && ref $p{to} eq "Node") {
        if (!$p{to}->graph) {
            say "$p{to} is no more?";
        }
        else {
            @links = @{$p{to}->graph->{links}}
        }
    }
    if ($p{from} && ref $p{from} eq "Node") {
        if (!$p{from}->graph) {
            say "$p{from} is no more?";
        }
        else {
            @links = @{$p{from}->graph->{links}}
        }
    }

    @links = map { main::order_link($p{from}, $_) } @links if $p{from};
    @links = grep { main::spec_comp($p{to}, $_) } @links if $p{to};

    return @links;
}

# trvl
sub goof {
    my ($start, $etc) = @_;
    if ($etc =~ /^\+ (#\w+) ?(\{\})?$/) { # + means autovivify
        my ($spec, $default) = ($1, $2);
        my @ed = $start->linked($spec);
        #confess "heaps of $spec from $start: ".Dump[@ed] if @ed > 1;
        my $ed = shift @ed;
        unless ($ed) {
            if ($default) {
                eval '$default = '.$default.';';
                confess "interpolating $default: $@" if $@;
            }
            $ed = $start->spawn($default);
            $ed->id($spec);
        }
        return wantarray ? ($ed, @ed) : $ed;
    }
    else {
        confess "goof $start: $etc is crazy";
    }
} # }}}

sub hook {
    my ($ex, $hook) = (shift, shift);
    return unless exists $ex->{$hook};
    $ex->{$hook}->($G, $ex, @_);
}
sub travel { # TRAVEL
    $G = shift || $G;
    my $ex = shift if ref $_[0] eq "HASH";
    $ex ||= {};
    $ex->{everywhere} = shift if ref $_[0] eq "CODE";
    unless ($ex->{seen_oids}) {
        $ex->{depth} = 0;
        $ex->{seen_oids} = {};
        $ex->{via_link} = undef;
    }
    hook($ex, "everywhere");

    if ($ex->{depth} > 500) {
        die "DEEP RECURSION!";
    }
    
    unless (ref $G eq "Node" && $main::objects_by_id{$G->{graph}}
        || ref $G eq "Graph" && $main::objects_by_id{$G->{uuid}}) {
        confess "graph $G->{graph} has been destroyed!";
    }
    my @links;
    if (ref $G eq "Node") {
        @links = getlinks(from => $G);
    }
    elsif (ref $G eq "Graph") {
        @links = map { { 1 => $_ } } @{$G->{nodes}};
    }
    hook($ex, "all_links", \@links);

    @links = grep { !$ex->{via_link} || $_ ne $ex->{via_link} } @links;
    hook($ex, "forward_links", \@links);

    @links = grep { ! exists $ex->{seen_oids}->{"$_->{1}"} } @links;
    hook($ex, "new_links", \@links);

    $ex->{seen_oids}->{"$G"} ||= { summarise($G) => [] }; #\@links };

    #die if grep { $G ne $_->{0} } @links;
    my $next_depth = $ex->{depth} + 1;
    my $previous = $G;
    for my $l (@links) {
        $G = $l->{1};
        $ex->{seen_oids}->{"$G"} ||= { summarise($G) => [] };
    }
    for my $l (@links) {
        my $ex = { %$ex };
        $ex->{via_link} = $l;
        $ex->{previous} = $previous;
        $ex->{depth} = $next_depth;
        $ex->{stack} = [@{$ex->{stack} || []}, summarise($G)];
        
        #say "TRAVELOONG $l->{0} -> $l->{1}";
        $G = $l->{1};
        travel($l->{1}, $ex, main::summarise($main::G))
    }
}

sub spec_comp {
    my $spec = shift;
    my $node = shift;
    my $l;
    if (ref $node eq "HASH") {
        $l = $node;
        $node = $l->{1};
    }
    my $thing = $node->{thing};

    if ($spec =~ /^#(.+)$/) {
        my $id = $1;
        return 0 unless defined $node->{id};
        if ($id =~ m{^/(.+)/$}) {
            $id = $1;
            return $node->{id} =~ $id;
        }
        else {
            return $node->{id} && $node->{id} eq $id;
        }
    }

    if ($spec =~ /^{(\w+) => (\.\.\.|\{\})\}$/) { # hash with key
        my $key_exists = $1;
        my $keys_value = $2;
        return ref $thing eq "HASH"
            && exists $thing->{$key_exists};
    }

    if ($spec =~ /^G\((.+?)\)$/) { # graph name
        my $name = $1;
        return ref $thing eq "Graph"
            && $thing->{name} =~ /$name/;
    }

    if ($spec =~ /^l\((\w+)\)$/) {
        my $linkval = $1;
        say "$linkval vs $l->{val}->[0]";
        return 1 if $l->{val}->[0] eq $linkval;
        return 0
    }

    return 1 if $spec && $spec eq "*";
    my $not = $spec =~ s/^!//;
    my $r = ref $spec   ? $node eq $spec      # an object
            : $spec     ? do {
                confess "still using non-ref spec: $spec";
                ref $node eq $spec  # package name
            }
            : 1;
    return !$r if $not;
    $r;
}

sub order_link { # also greps for the spec $us
    my ($us, $l) = @_;
    if (spec_comp($us, $l->{0})) {
        return $l
    }
    elsif (spec_comp($us, $l->{1})) {
        return {
            1 => $l->{0}, 0 => $l->{1},
            val => $l->{val}, _id => "$l",
        }
    }
    return ()    
}

sub summarise { # SUM # SOOM
    my $thing = shift;
    my $text;
    no warnings "experimental";
    given (ref $thing) {
        when ("Graph") {
            $text = "Graph ".($thing->{name}||"~noname~")." ".($thing->{uuid}||"~nouuid~")
        }
        when ("Node") {
            my $inner = $thing->thing;
            my $id = $thing->id;
            my $graph = $thing->graph;
            my $graph_name = $graph ? $graph->name : "ORPHAN";
            $text = "N($graph_name) ".($id ? "$id " : "").summarise($inner);
            unless (ref $inner eq "Node") {
                my $addy = $thing->{uuid};
                $text .= " $addy"
            }
        }
        when ("HASH") {
            if ($thing->{code}) {
                $text = '$code'
            }
            else {
                eval {
                $text = encode_json($thing)
                };
                if ($@) {
                    $text = Dump($thing);
                    say "but whatever: $@";
                }
                $text =~ s/^(.{40})(.+)$/"$1...".length($2)/e;
            }
        }
        when ("ARRAY") {
            eval {
            $text = encode_json($thing)
            };
            if ($@) {
                $text = Dump($thing);
                say "but whatever: $@";
            }
            $text =~ s/^(.{40})(.+)$/"$1...".length($2)/e;
        }
        when ("CODE") {
            $text = "code";
        }
    }
    if (!defined $thing) {
        $text = "~undef~";
    }
    $text ||= "$thing";
    return $text;
}


sub tup {
    my $tuple = shift;
    ref $tuple eq "ARRAY" ? @$tuple : $tuple;
}
sub uniquify_id {
    my ($pool, $string) = @_;
    while (exists $pool->{$string}) {
        $string =~ s/(\d*)$/($1||1)+1/e;
    }
    return $string
}

sub displow {
    my $ob = shift;
    my @lines;
    travel($ob, { everywhere => sub {
        my ($G, $ex) = @_;
        push @lines, join '', (" ") x $ex->{depth}, summarise($G);
    } } );
    return join "\n", map { s/ \(.+?\)$//; $_; } @lines;
}


# }}}

mach_spawn("#tout", sub { #{{{
    my ($self, $mojo, $client) = @_;
    $mojo->drawings(Load("tout.yml"));
}, "toolbar");#}}}

mach_spawn("#trippyboxen", sub { # {{{
    my ($self, $mojo, $clunt, $id) = @_;

    $machs->linked("#trippyboxen_setup")->thing->();

    my $in = -300;
    my $rotate;

    my $idi = 0;
    my $elements = sub {
        my @elements;
        $rotate = "30 100 100";
        for my $d (-15..15) {
            $d = ($d / 15) * 50 * ($d / 14);
            for (1..5) {
                $in += 15;
                push @elements, [ 'boxen',
                    500 + $_ * 10 - $d * ($d - (1 * ($in / 30))),

                    50 * $_ - $d,

                    40, 40, {
                    fill => "555",
                    stroke=> "000",
                    id => "trippy".$idi++,
                } ];
            }
        } # '"'
        @elements;
    };
    my @elements = do {
        my $in = 0;
        $elements->();
    };
    my @elements2 = $elements->();
    my @anims;
    for my $e1 (@elements) {
        my $e2 = shift @elements2;
        my $x = $e1->[1] - $e2->[1];
        my $y = $e1->[2] - $e2->[2];
        my $rotate = $rotate;
        $rotate =~ s/^(\d+)/$1 + ($e2->[2] * 4) \/ ($1 * 0.7) /e;
        push @anims, ["animate", $e1->[-1]->{id},
                    {svgTransform => "rotate($rotate) translate($x $y)",
                    svgStrokeWidth => 3,
                    svgStroke => "white",
                    svgFillOpacity => 0.3},
                    5000]
    }

    $machs->linked("#trippyboxen_controls")->thing->();

    push @elements, @anims;

    $mojo->drawings(['clear'], @elements);

}, "toolbar",
{
    open_guts => "mach trippyboxen",
    from => qr/elements = sub/,
    to => qr/\@elements;/,
    controls => "numbercrankers",
    y => 400,
},
); # }}}


mach_spawn("#dsplay", sub { #{{{
    my ($self, $mojo, $client) = @_;
    start_timer();
    my $dump = load_graph_yml("td.yml");
    say "Load graph took: ".show_delta();
    my $begin = $dump->find("#find") || $dump;
    get_object($mojo, $begin->{uuid});
});#}}}

mach_spawn("#reexamine", sub { # {{{
    my ($self, $mojo, $client) = @_;

    my $exam = find_latest_examination($self, $mojo, $client)->thing;
    my $svg = $client->linked("#svg");
    my $remove_later = {};
    my @drawings = map {
        map {
            $_->[0] =~ /^(label|boxen)$/ || die "Nah ". Dump $_;

            $_->[1] += demagnetise_coord( x => 0.4 );

            my $classid = $_->[-1]->{id}."_reexamine";
            $_->[-1]->{class} .= " $classid";
            $remove_later->{$classid}++;

            $_
        } @{ dclone($_)->{elements} }
    } map { $_->{val}->[0] }
    grep { $_->{1}->{graph} eq $exam->{uuid} } $svg->links;

    later_id_remover("reexamine", keys %$remove_later);

    return $mojo->drawings(@drawings);
}, "toolbar"); # }}}


mach_spawn("#refrank", sub { # {{{
    my ($self, $mojo, $cliuent, $id) = @_;
    `kill $frankpid`;
    frankenfork();
    sleep 1;
    $machs->linked("#notation")->thing->(@_) unless $id;
}, 'toolbar'); # }}}

mach_spawn("#hits", sub { # {{{
    my ($self, $mojo, $client) = @_;

    my $exam = find_latest_examination($self, $mojo, $client)->thing;
    my $svg = $client->linked("#svg");
    my $remove_later = {};

    my @notation = read_file('notation');
    my $i = 0;
    my $hits = {};
    for (@notation) {
        my ($sub) = /^\s+'(.+?)'/;
        $hits->{$sub}++;
    }

    my @drawings = map {
        map {
            # add the number of hits beside the subroutine
            my $label = $_;
            if ($label->[3] =~ /::/) {
                my $id = $label->[-1]->{id};
                my $classid = $id."_hits";
                $label->[-1]->{class} .= " $classid";
                $remove_later->{$classid}++;

                $label->[1] += 300;

                my $total = $hits->{$label->[3]} || '0';
                $label->[3] = "hit $total times";

                $label
            }
            else {
                ()
            }
        } grep { $_->[0] =~ /label/ }
            @{ dclone($_)->{elements} }
    } map { $_->{val}->[0] }
    grep { $_->{1}->{graph} eq $exam->{uuid} } $svg->links;

    later_id_remover("hits", keys %$remove_later);

    return $mojo->drawings(@drawings);
}, "toolbar"); # }}}

sub later_id_remover { #{{{
    my ($from, @ids) = @_;

    attach_for_once('scope/changing_object', "#tidyup_$from", sub {
        my ($self) = @_;
        my $rms = $self->linked("#removals")->thing;
        push @$rms, map { [ remove => $_ ] } @ids;
    });
}

sub attach_for_once {
    my ($where, $named, $sub) = @_;

    my $detach_us = sub {};

    my $us = mach_spawn($named, sub {
        $sub->(@_);
        $detach_us->();
    });

    attach_stuff($where, $us);
    $detach_us = sub {
        detach_stuff($where, $us);
    };
} #}}}

mach_spawn("#dump_trail", sub { # {{{
    my ($self, $mojo, $client) = @_;
    my $trail = $client->linked("#trail")->thing;
    say join "", map { 'restep("'.join('", "', @$_).'");'."\n" } @$trail;
    return $mojo->drawings([status => "dumped trail to console"]);
}, "toolbar"); # }}}



$webbery->spawn("#clients"); # {{{

# {{{ define the TOOLBAR
$toolbar->link($webbery);
$toolbar->link($P);
$toolbar->link($scope);
if (my $cg = $webbery->find("#codegraph")) {
    $toolbar->link($cg->thing);
}
sub scopify_toolbar {
    return if $scope->find("#toolbar");
    my $y = 20;
    my $x = demagnetise_coord( x => -35 );

    # in the future you'd link $scope to $toolbar with algorithm to grab what's displaying and how
    my @new;
    for my $ble ($toolbar->linked()) {
        if (ref $ble->thing eq "Graph") {
            $ble = $ble->thing;
        }
        my $sum = summarise($ble);
        my ($name, $id, $color) = nameidcolor($sum);
        $name = "$name $id";
        $sum =~ s/ .{12}$//;
        $y += 40;
        push @new, ["boxen", $x, $y, 30, 30,
                { fill => $color, name => $name, id => $id, } ],
            ["label", $x - length($sum)*8.5, $y, $sum,
                { id => $id } ]
    }
    my $toolbarn = $scope->spawn("#toolbar");
    $toolbarn->spawn($_) for @new;
}
# }}}


# TODO also is stateless data access functions, so butter can interrogate frankenbutter

use Mojolicious::Lite;
get '/hello' => \&hello;
sub home {
    return $webbery->find( # butter      frankenbutter
        $port eq "3000" ? "#notation" : "#trippyboxen"
    )->{uuid}
}
sub hello {
    my $mojo = shift;

    my $clients = $webbery->find("#clients");

    # trash the old state
    for my $client ($clients->linked()) {
        $clients->unlink($client);
        $client->trash;
    }

    $clients->spawn("the")->in_field(sub {
        $client = shift;
        $client->id("#client");
        $client->spawn([])->id("#trail");
        $client->spawn("#svg");
        $client->spawn({})->id("#translates");
    });

    $mojo->render(json => [object => { id => home() }]);
}
get '/width' => sub {
    my $mojo = shift;
    my $width = $mojo->param('width');
    $client->in_field(sub{
        shift->spawn($width)->id("width");
    });
    scopify_toolbar();
    $mojo->render(json => "Q");
};

sub nameidcolor { #{{{
    my $summarised = shift;
    if ($summarised =~
        m{^(?:N\(.+?\) )*(.+) (.+(...))$}) {
        my ($name, $id, $color) = ($1, $2, $3);
        $name = "$name $id";
        return ($name, $id, $color);
    }
    else {
        return ("$summarised", "???", "000");
    }
};#}}}

sub examinate_graph {
    my $graph = shift;

    my $exam = new Graph('graph-exam');
    $exam = $exam->spawn("Graph exam");

    if ($graph->{name} eq "codes") {
    }
    else {
        $graph->map_nodes( sub {
            $exam->spawn(shift);
        } );
    }

    return $exam;
}

attach_stuff("get_object/01", mach_spawn("#track", sub { # {{{
    my ($self, $mojo, $client) = @_;

    my $id = $self->linked("#id")->thing;

    my $trail = $client->linked("#trail")->thing;

    if (home() eq $id && @$trail == 0) {
        push @$trail, [ "home" ];
        return;
    }

    for my $n ($toolbar->linked()) {
        if ($n->{uuid} eq $id) {
            push @$trail, [ "toolbar", summarise($n) ];
            return;
        }
    }

    my $exam = find_latest_examination(undef, undef, $client);
    if ($exam) {
        my $svg = $client->linked("#svg");
        $exam = $exam->thing;
        my %by_y;
        $exam->map_nodes(sub {
            my $n = shift;
            my ($svgl) = $svg->links($n);
            my $y = $svgl->{val}->[0]->{y};
            $by_y{$y} = $n;
        });
        for my $y (sort keys %by_y) {
            my $n = $by_y{$y};
            if ($n->thing eq "Graph") {
                say Dump($n->thing);
            }
            if ($n->thing->{uuid} eq $id) { # summarise($n->thing) =~ $id) {
                push @$trail, [ "exam", $y, summarise($n) ];
                return;
            }
        }
    }

    if (home() eq $id) {
        push @$trail, [ "home" ];
        return;
    }

    push @$trail, [ "?" ]; # eg some mach generates a get_object call
})); # }}}
# }}}

get '/object' => \&get_object;
sub get_object { # OBJ
    my $mojo = shift;

    defined $client || return $mojo->sttus("hit F5!");
    my $id = shift || $mojo->param('id')
        || die "no id";

    say "ID: $id";
    if ($id =~ /_ctrl_/) {
        return do_stuff('get_object/ctrl', $mojo, $id);
    }

    my $self = $client->spawn("#get_object");
    $self->in_field(sub {
        shift->spawn($id)->id('id');
    });

    my $object = object_by_uuid($id);

    unless ($object) {
        # this must be some made-up id of a mach's internals
        if (do { $object = $client->linked("#object") }
            && ref $object->thing eq "Node"
            && $machs->linked($object->thing)) {

            return $object->thing->thing->($object, $mojo, $client, $id);
        }
        else {
            return $mojo->sttus("$id no longer exists!");
        }
    }

    my $r = do_stuff('get_object/01', $self, $mojo, $client, $object);
    if ($r->{changeofplan} && $r->{changeofplan} eq "return") {
        # TODO better than this
        return;
    }

    if (ref $object eq "Node") {
        if ($machs->linked($object)) {
            the_object($object);
            return $object->thing->($object, $mojo, $client);
        }
    }

    the_object($object);
    examinate_object($self, $mojo, $object, $id);
}

sub the_object { # hook here...
    my $object = shift;
    $_->trash() for $client->linked("#object");
    $client->spawn($object)->id("#object");
}

sub examinate_object {
    my ($self, $mojo, $object, $id) = @_;

    start_timer();
    my $status = "For ". summarise($object);
    if (ref $object eq "Graph") {
        # can't traverse from a graph so create a list of Nodes and continue with that
        $object = examinate_graph($object);
    }
    elsif (ref $object eq "Node") {
        # alright!
    }
    else {
        confess ref $object;
        return $mojo->sttus("don't like to objectify ".ref $object);
    }

    $self->spawn($object)->id('object');

    my $viewed = find_latest_examination($self, $mojo, $client);
    $client->spawn($viewed)->id("#viewed") if $viewed;

    if ($TEST) {
        $TEST->spawn($viewed)->id("viewed");
        if (my $h = $TEST->linked("#viewed_hook")) {
            $h->thing->();
        }
    }

    ($viewed, my $viewed_node) = ($viewed->thing, $viewed) if $viewed;

    make_traveller($self, $mojo, $client);
    my $exam = search_about_object($self, $mojo, $client);
    if ($TEST) {
        $TEST->spawn($exam)->id("exam");
        if (my $h = $TEST->linked("#exam_hook")) {
            $h->thing->();
        }
    }

    for (qw'drawings animations removals') {
        $self->spawn([])->id($_);
    }

    # TODO
    generate_svg($self, $mojo, $client);
    if ($TEST) {
        if (my $h = $TEST->linked("#svg_hook")) {
            $h->thing->();
        }
    }

    diff_svgs($self, $mojo, $client);

    fill_in_svg($self, $mojo, $client);

    my $clear;
    if (!$viewed) { # TODO hmm
        $clear = "viewed";
    }

    unless (@{ $self->linked("#animations")->thing }) {
        $clear = "noanim";
    }
    main::do_stuff('scope/changing_object', $self, $mojo, $client); # TODO clinging to existence

    if ($TEST) {
        use Storable 'dclone';
        $TEST->spawn(dclone {
            id => $id,
            removals => $self->linked("#removals")->thing,
            animations => $self->linked("#animations")->thing,
            drawings => $self->linked("#drawings")->thing,
        })->id("#drawings");
    }

    my @drawings;
    for (qw'removals animations drawings') {
        my $bit = $self->linked("#".$_);
        unless ($clear && $_ eq "removals") {
            push @drawings, grep {
                !($_->[0] eq "animate" && $_->[2]->{svgTransform} eq "translate(0 0)" )
            } @{ $bit->thing };
        }
        for my $l ($bit->links) {
            $bit->unlink($l);
        }
        $self->graph->denode($bit);
    }

    unshift @drawings, ["status", $status];
    if ($clear) {
        $drawings[0]->[1] .= "(clear=$clear)";
# TODO the rest of the screen should be structured graph
# theres probably a group thing in svg that can tidily remove etc...
        unshift @drawings, ["clear", $clear];
        if ($TEST) {
            $TEST->spawn($drawings[0])->id("#clear");
        }
    }
    for my $old_viewed ($client->linked("#viewed")) {
        trash_viewed_exam($client, $old_viewed);
    }
    $self->trash();
    say $status ." in ". show_delta();
    $mojo->drawings(@drawings);
};

sub trash_viewed_exam { # {{{
# this should be more like a hook on the client->exam link destruction
# al-so placing the exam #viewed should happen upon client->self (get_object) destruction
# then it's all ready for the next round
# get_object should have more clearly defined persistances I guess
# sort out some time when we can see things happening
    my ($client, $viewed) = @_;
    my $exam = $viewed->thing->thing;
    ref $exam eq "Graph" || confess "not graph: ".summarise($exam);
    my $svg = $client->linked("#svg");
    for (uniq map { $_->{1} }
        grep { $_->{1}->{graph} eq $exam->{uuid} } $svg->links()) {
        $svg->unlink($_);
        $_->graph->denode($_);
    }
    $client->unlink($viewed);
    $viewed->graph->denode($viewed);
}

sub find_latest_examination {
    my ($self, $mojo, $client) = @_;

    my @exams = $client->linked("#/^object-examination/");

    @exams = sort {
        ($a, $b) =
            grep { s/^.+?(\d+)$/$1/ || s/^.+$/1/ }
            map { $_->thing->{name} } $a, $b;
        $a <=> $b
    } @exams;

    my $latest = pop @exams;
    for my $old_viewed ($client->linked("#viewed")) {
        warn "Got an old #viewed exam: ".summarise($old_viewed);
        trash_viewed_exam($client, $old_viewed);
    }
    return $latest;
}

sub make_traveller {
    my ($self, $mojo, $client) = @_;
    if ($self->linked("#traveller")) {
        Carp::cluck "traveller exists already..."
    }
# TODO for traversing for get_object without running into backstage stuff
# fields to outdate?
    my $traveller = Travel->new(
        ignore =>
            ["->{iggy}", "#object-examination", "#ids"],
    );
    $self->spawn($traveller)->id("#traveller");
}

sub search_about_object {
    my ($self, $mojo, $client) = @_;
    my $object = $self->linked("#object")->thing;
    my $traveller  = $self->linked("#traveller")->thing;
    my $exam = search(
        start => $object,
        spec => '**',
        want => "G(object-examination)",
        traveller => $traveller,
        forward_links => sub {
            my ($G, $ex, $links) = @_;
            if (ref $G eq "Node" && $G->id && $G->id eq "svg") {
                @$links = () unless $ex->{depth} < 2;
            }
        },
    );
    for ($self, $client) {
        $_->spawn($exam)->id("#object-examination");
    }
    return $exam;
} # }}}

sub generate_svg { # {{{
    my ($self, $mojo, $client) = @_;

    my $ids = goof($client, "+ #ids {}")->thing;
    my $getid = sub {
        my $id = uniquify_id($ids, shift);
        $ids->{$id} = undef; # TODO eh
        return $id;
    };
    my $exam = $self->linked("#object-examination")->thing;
    my $traveller  = $self->linked("#traveller")->thing;
    my $svg = $client->linked("#svg");

    my $y = 0;

    $traveller->travel($exam->first, sub {
        my ($en, $ex) = @_;
        my $n = $en->thing;
        my $thing = $n;

        $thing = ref $thing eq "Node" ? $thing->{thing} : "G=$thing->{name}";

        $svg->link($G, {
            y => $y++,
            x => $ex->{depth},
        });
    });
} # }}}

sub diff_svgs { # {{{
    my ($self, $mojo, $client) = @_;

    my $drawings = $self->linked("#drawings");
    my $animations = $self->linked("#animations");
    my $removals = $self->linked("#removals");

    my $traveller = $self->linked("#traveller")->thing;
    my $viewed = $client->linked("#viewed");
    $viewed = $viewed->thing if $viewed;
    $viewed = $viewed->thing if $viewed;
    my $exam = $self->linked("#object-examination")->thing;
    my $svg = $client->linked("#svg");

    my %new_uuids;
    $traveller->travel($exam->first, sub {
        my ($new, $ex) = @_;
        $new_uuids{$new->thing->{uuid}}++;

        my @old = $viewed->find($new->thing) if $viewed;
        # for not hittting the same thing twice in the old exam
        my $old_i = $new_uuids{$new->thing->{uuid}} - 1;
        my $oldn = $old[$old_i];

        if ($oldn) {
            $animations->link($new, $oldn);
        }
        else {
            $drawings->link($new);
        }
    });

    if ($viewed) {
        $traveller->travel($viewed->first, sub {
            my ($old, $ex) = @_;
            unless ($new_uuids{$G->thing->{uuid}}
                && $new_uuids{$G->thing->{uuid}}-- > 0) {
                $removals->link($old);
            }
        });
    }
}

sub chlnkg {
    my ($new, $anim, $draw) = @_;
    my @an = $anim->linked($new);
    my @dr = $draw->linked($new);
    unless (@an == 1 || @dr == 1) {
        die Dump{anim=>\@an, draw=>\@dr};
    }
} # }}}


sub fill_in_svg { # {{{
    my ($self, $mojo, $client) = @_;

    my $drawings = $self->linked("#drawings");
    my $animations = $self->linked("#animations");
    my $removals = $self->linked("#removals");
    my $translates = $client->linked("#translates")->thing;
    my $traveller = $self->linked("#traveller")->thing;
    my $viewed = $client->linked("#viewed");
    $viewed = $viewed->thing if $viewed;
    $viewed = $viewed->thing if $viewed;
    my $exam = $self->linked("#object-examination")->thing;
    my $svg = $client->linked("#svg");

# fill out svg first
# turn divvy up animations

# svg element removal is by class so lets use oaid
# TODO removals' olds should be a field so it don't find its links to $self
    my $viewed_uuid = $viewed ? $viewed->{uuid} : "nothing";
    for my $old (grep { $_->{uuid} eq $viewed_uuid } $removals->linked) {
        my ($oaid) = map { $_->{val}->[0]->{oaid} } $svg->links($old);
        say "old is ".$old." ".summarise($old);
        $oaid || die;
        eval {
            $svg->unlink($old);
        };
        if ($@ && $@ =~ /nothing to unlink/) {
            say "Nothing to unlink svg -> ".Dump($G);
        }
        else {
            die $@ if $@;
        }
        push @{ $removals->thing }, [remove => $oaid];
    }

# oaid    $uuid-$sn             class on the bunch of things for this exam $G
# id        $oaid-[bcl]$sn?     id on the svg element
    my $e_by_tuuids = {};
    my $e_by_y = {};
    $traveller->travel($exam->first, sub {
        my ($new, $ex) = @_;

        chlnkg($new, $animations, $drawings);
        ($new->thing->{graph} || $new->thing->{uuid}) ne $exam->{uuid} || die;

        # gather uuids for possible indexing
        my $tuuid = $new->thing->{uuid};
        my $euuid = $new->{uuid};
        my $by = $e_by_tuuids->{$tuuid} ||= [];
        push @$by, $new;

        # by y position
        my ($y) = map { $_->{val}->[0]->{y} } $svg->links($new);
        $e_by_y->{$y} && die;
        $e_by_y->{$y} = $new;
    });

    for my $y (sort keys %$e_by_y) {
        my $new = $e_by_y->{$y};
        my ($svgv) = map { $_->{val}->[0] } $svg->links($new);
        $svgv || die;

        my $oaid = do {
            my $tuuid = $new->thing->{uuid};
            my @es = $e_by_tuuids->{$tuuid};
            @es > 0 || die;
            
            if (@es > 1) {
                my $i = 0;
                $i++ until $es[$i] eq $new;
                $tuuid .= "-$i";
            }
            $tuuid;
        };

        my $stuff = summarise($new->thing);
        my ($name, $id, $color) = nameidcolor($stuff);
        my (@elements, $height);

        my $new_oaid = do_stuff('fill_in_svg/oaid', $self, $new, $oaid);
        $oaid = $new_oaid if $new_oaid && ref $new_oaid ne "HASH";

        push @elements, [ 'boxen', -20, -2, 18, 18, {
            fill => $color,
            name => $name,
            id => "$oaid",
        } ];

        if (ref $new->thing eq "Node" &&
            ref $new->thing->thing eq "HASH" && $new->thing->thing->{code}) {
            my $li = 0;
            my $code = $new->thing->thing->{code};
            $code =~ s/\s+\Z//sgm;
            $code =~ s/(?<=\n\n)\n+//sgm;
            for my $line (split /\n/, $code) {
                my ($ind) = $line =~ /^( +)/;
                my $x = (length($ind || "")) * 10;
                my $y = $li * 14;

                unshift @elements, [ 'label', $x, $y, $line, {
                    id => "$oaid-l$li",
                } ];
                $li++;
            }
            $height = ($li+1) * 14;
        }
        else {
            my %etc;
            if ($new->linked > 2) {
                $etc{'font-weight'} = "bold";
            }
            if ($new->thing->graph->name eq "shortcodegraph"
                && ref $new->thing->thing ne "") {
                $stuff = $new->thing->thing->{sub};
            }
            push @elements, [ 'label', 0, 0, $stuff, {
                id => "$oaid-l",
                %etc,
            } ];
        }

        for my $e (@elements) {
            my $a = $e->[-1];
            $a->{class} = "";
            $a->{class} .= "$a->{fill} " if $a->{fill};
            $a->{class} .= $oaid;
        }

        $height ||= 20;
        $svgv->{height} = $height;
        $svgv->{elements} = \@elements;
        $svgv->{oaid} = $oaid;
    }

    my ($posx, $posy) = (30, 40);
    my $new_translates = {};
    my $y_add = 0;
    for my $y (sort keys %$e_by_y) {
        my $new = $e_by_y->{$y};
        my ($svgv) = map { $_->{val}->[0] } $svg->links($new);
        $svgv || die;

        my $y = $y * 20 + $y_add + $posy;
        my $x = $svgv->{x} * 20 + $posx;
        for my $e (@{$svgv->{elements}}) {
            $e->[1] += $x;
            $e->[2] += $y;
        }

        if (my ($anim_l) = $animations->links($new)) {
            my ($old) = $anim_l->{val}->[0];
            $old || die;
            my ($old_svgv) = map { $_->{val}->[0] } $svg->links($old);
            $old_svgv || die;
            
            confess unless @{$old_svgv->{elements}} == @{$svgv->{elements}};

            my $eg = [$old_svgv->{elements}->[0], $svgv->{elements}->[0]];
            my $dx = $eg->[1]->[1] - $eg->[0]->[1]; # new - old x
            my $dy = $eg->[1]->[2] - $eg->[0]->[2]; # new - old y

            say "Oacid diffrances" unless $old_svgv->{oaid} eq $svgv->{oaid};
            my $trid = $old_svgv->{trid} || $svgv->{oaid};
            $svgv->{trid} = $trid;

            my $trans = $translates->{$trid};
            $trans->{x} += $dx;
            $trans->{y} += $dy;
            $new_translates->{$trid} = $trans;

            for my $e (@{ $svgv->{elements} }) {
                my $id = $e->[-1]->{id};
                push @{ $animations->thing },
                    ["animate", $id,
                    {svgTransform => "translate($trans->{x} $trans->{y})"},
                    300]
            }
        }
        elsif ($drawings->linked($new)) {
            push @{ $drawings->thing },
                @{ $svgv->{elements} }
        }
        else {
            die;
        }
        $y_add = $y_add + ($svgv->{height} - 20);
    }
    %$translates = %$new_translates if %$new_translates;
    return;
} # }}}

get '/object_info' => sub {
    my $mojo = shift;
    $mojo->sttus("shag off!");
};

get '/' => 'index';

no warnings 'once';
*Mojolicious::Controller::drawings = sub {
    my $mojo = shift;
    my @drawings = @_;

    if (@drawings == 1 && $drawings[0]->[0] eq "status") {
        $mojo->render(json => [@drawings]);
    }

    my @sdc;
    my $loose = {};
    $scope->map_nodes(sub {
        if ($_[0]->id) {
            push @sdc, $_[0]
        }
        else {
            $loose->{$_[0]->{uuid}} = $_[0]
        }
    });
    my @more_drawings;
    for my $cluster (@sdc) {
        for ($cluster->linked) {
            push @more_drawings, $_->thing;
            delete $loose->{$_->{uuid}};
        }
    }
    if (@more_drawings) {
        say scalar(@more_drawings)." G(scope) drawings from: ".
            join(", ", map { $_->id } @sdc);
    }
    my @removes;
    if (keys %$loose) {
        for my $d (values %$loose) {
            push @removes, ["remove" => $d->thing->[-1]->{id}]
        }
        $scope->denode(values %$loose);
    }
    say "and ".scalar(@removes)." removals" if @removes;

    push @drawings, @more_drawings, @removes;

    say scalar(@drawings)." drawings";

#    DumpFile("drawings.yml", [@_]);
    $mojo->render(json => [@drawings]);
};
*Mojolicious::Controller::sttus = sub {
    my $mojo = shift;
    $mojo->drawings(["status", shift]);
};
use warnings;

return 1 if caller;
use Mojo::Server::Daemon;
my $daemon = Mojo::Server::Daemon->new;
$daemon->listen(['http://*:'.$port]);
web_run();

sub web_run {
    $daemon->run;
}
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>scap!</title>
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

