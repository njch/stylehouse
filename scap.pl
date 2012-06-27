#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

our $json = JSON::XS->new()->convert_blessed(1);
our %satan;
my @boxen;
our $y = 5;
sub linkery {
    my $l = shift;
    my ($parent, $child);
    for (0, 1) {
        my ($name, $id, $color) = "$l->{$_}" =~ m{^(\w+)=.+\((0x...(...).)\)$}
            or die "HUr";
        $name = "$name $id";
        my $tup = [ $name, $id, $color ];
        unless ($parent) {
            $parent = $tup
        }
        else {
            $child = $tup
        }
    }
    my $p = $satan{$parent->[1]} ||= do {
        $y += 20;
        push @boxen, [label => 8, $y => $parent->[0]];
        [160, $y];
    };
    $p->[0] += 20; # line height/leading... text coorded from bottom of line
    push @boxen, [boxen => @$p, 18, 18,
        { fill => $child->[2], name => $child->[0], id => $child->[1] } ];
}

=pod USER INTERFACE
we need to be able to define views which graph the graph subsets in 2d space.

the client asks for some kind of view
the objects in view are poked into the svg
clickthrough to more views
some clicks/drags/whatevers eventually get shit done
yep
etc

then we can click things around. construction then.
then we introduce all the debugging features that require some UI
 - the program should be able to mess with core programming and test itself,
 bootstrapping into itself when ready...
 - the state of the graphics frontend is just data about the other data,
   it should all be able to survive program restart
right so get educated about SVG
=cut



=pod THE THICKNESS OF GRAPH
So there's usually just one graph per App
App would branch away its various data but it's one bunch of links

linking more in a graph means node linkage
linking an alien object means it is put in a node and the node is linked in
the node is appropriately transparent:
    ->links() for eg is a node method, non-node method calls are passed
    through the node so $G is set up for any graphy business the object wants

this is all so we can fork an App in a certain state better

we also want to create graphs that are subsets of larger graphs
each node in the subset could be linked to the original in secret way
(if a query asked it could traverse back into the original graph)
once we have subsets carved out we can run them into algorithms easier
the technology of mingling various @links is probably like having data stores

there's kind of a turf concept going on... various customs for travellers...

case study of different graphs, as a flow diagram:
    run a graph query
    figure out how to SVG the results
      - sorting branches
      - spacing things out...
    diff that SVG <-> user's SVG
    drawing instructions for the user's SVG canvas

we're almost up to here... not spacing things out though

there's some fun data analysis to be done with graphing the graph from
various points and finding patterns in the translation data given to the
client. if you make things move twice as far as they should things
start meandering off in groups of likeness. hail the complexity!

some time when can think proper, about object()'s subset graphs and
svging relating to Nodes... err.. nah missed it good luck.
aha see for instance $viewed->find($new->thing);
yes

fields, :field, whatever, could speed things up by partitioning the various
arrays of nodes. a thing in one field would travel in its own field first,
then outwards... The Field is given by links...
the syntax for dealing with this machine needs to imply the sanest
dont forget this should be the simplest incantation of "fields", turns into
all sorts of contextuality the further you go up the pyramid...
this needs guitar playing meditation after a quick briefing?

RIGHT so start here:
Welcome to Wednesday. Make web ids really unique.
Graph things out so there can be the "graph" and the "toolbar"
Make a tool graph already, for doing the things object() does.
the atoms won't be round, they're individual but woven into each other.
=cut

=pod
to migrate this code from the one-graph model to the graph-nodery-object model...
bring back the Tracer hack, with timestamps, and capture the current graphening into a new Graph
yes... get the application "testable" through the UI (which needs some Graph extravaganze)
  meaning you can fire it off and see the Tracer/etc graph/etc that it outputs
  graph differencible development primitively progresses...

so eventually the Graph/Node infrastructure code will be represented on itself
so hacks can be loaded in without impurifying the basic apparition of IT.
those hacks, being datastructure concerns, should be compiled back into CODEs
the system tests the new tech then just changes some links to hop over to it
=cut

sub uniquify_id {
    my ($pool, $string) = @_;
    while (exists $pool->{$string}) {
        $string =~ s/(\d*)$/($1||1)+1/e;
    }
    return $string
}

our %graphs;
package Graph;
use strict;
use warnings;
sub new { # name, 
    shift;
    my $self = bless {}, __PACKAGE__;
    $self->{name} = main::uniquify_id(\%main::graphs, shift || "unnamed");
    $self->{links} = [];
    $self->{nodes} = [];
    $main::graphs{$self->{name}} = $self;
    return $self
}
sub name {
    return $_[0]->{name};
}
sub link {
    my ($self, $I, $II, @val) = @_;
    $I = $self->spawn($I) unless ref $I eq "Node";
    $II = $self->spawn($II) unless ref $II eq "Node";
    die "diff graphs: ".$I->graph->{name}." vs ".$II->graph->{name}.":  ". main::summarise($I) . "\t\t" . main::summarise($II)
        if $I->graph ne $II->graph && 0;
    my $l = {
        0 => $I, 1 => $II,
        val => \@val,
    };
    push @{$self->{links}}, $l;
    $self->{when_link} && $self->{when_link}->($self, $l);
}
sub unlink {
    my ($self, @to_unlink) = @_;
    my %to_unlink;
    $to_unlink{"$_"} = undef for @to_unlink;
    my $links = $self->{links};
    for my $i (@$links-1..0) {
        if (exists $to_unlink{$links->[$i]}) {
            splice @$links, $i, 1;
            delete $to_unlink{$links->[$i]};
            return unless keys %to_unlink;
        }
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
        if ($_[0]->{thing} eq $thing) {
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
sub DESTROY {
    my $self = shift;
    for my $l (@{$self->{links}}) {
        delete $l->{$_} for keys %$l;
    }
    undef $self->{links};
    undef $self->{nodes};
};
package Node;
use strict;
use warnings;
use List::MoreUtils 'uniq';
sub new { # graph => name, 
    shift;
    my $self = bless {}, __PACKAGE__;
    my %params = @_;
    $self->{graph} = $params{graph}->name;
    my @fields = main::tup($params{fields}); # detupalises?
    $self->{fields} = \@fields;
    $self->{thing} = $params{thing};
    return $self
}
sub TO_JSON {
    my $self = shift;
    return join "  ", "$self:", %$self
}
sub spawn {
    my $self = shift;
    my $spawn = $self->graph->spawn(shift);
    $self->link($spawn, @_);
    $spawn->{fields} = $self->{fields} if $self->{fields};
    return $spawn;
}
sub field {
    my $self = shift;
    $self->{fields} = shift if $_[0];
    $self->{fields};
}
sub trash {
    my $self = shift;
    my $field = shift;
    # TODO travel to the extremities of $field deleting everything...
    map { $self->unlink($_); $_->DESTROY if ref $_ eq "Graph" }
    grep { $_->{field} && $_->{field} eq $field} $self->linked;
    $self->unlink($_) for $self->linked;
}
sub graph {
    $main::graphs{$_[0]->{graph}} || die "no graph $_[0]->{graph}";
}
sub link {
    $_[0]->graph->link(@_)
}
sub unlink {
    my ($self, $I, @others) = @_;
    # finding all links from $_[1] to $_[2..]s seems silly
    my @links;
    for my $o (@others) {
        for my $l ($I->links($o)) {
            push @links, $l
        }
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
    local @main::links = @{$self->graph->{links}};
    if (!$spec) {
        return main::getlinks(from => $self);
    }
    else {
        return main::search(
            start_from => $self,
            spec => $spec,
        );
    }
}
sub thing {
    shift->{thing}
}
package Travel;
use strict;
use warnings;
sub new {
    shift;
    my %p = @_;
    my $self = bless {}, __PACKAGE__;
    if ($p{ignore}) {
        $self->ignore($p{ignore});
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
    my $ex = {};
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
              :
            die "don't know how to ignore a $_"
        } main::tup($self->{ignore});
        say "Ingores: ".join" ", main::tup($self->{ignore});
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
    main::travel($main::G, $ex);
}
package Tracer;
sub new {
    shift;
    bless {val => \@_}, __PACKAGE__
}
sub D {
    my $self = shift;
    return if $self->{nore};
    @main::tracers = @main::tracers[0..$self->{n}-1];
}

package main;

our @findable_objects;
our $no_more_tracery = 0;
our $trace = new Graph ("Trace");
my $trace_head = $trace->spawn(new Tracer("/"));
push @findable_objects, $trace_head;
our @tracers = ("b", $trace_head);

my $nore = 0;
package NotTracer;
sub new { bless {}, __PACKAGE__ };
sub D {};
package main;
sub trace {
    return NotTracer->new() if $no_more_tracery;
    $nore++;
    my $t = $tracers[-1]->spawn(new Tracer(@_)) unless $nore > 1;
    $t->{thing}->{n} = @tracers;
    push @tracers, $t;
    say(("  " x @tracers) ." ".$json->encode(\@_));
    if (@tracers > 100) {
        die "yay many";
    }
    $nore = 0;
    return $t->{thing};
}

our $junk = new Stuff("Junk");
my $wants = new Stuff("Wants");
my $code = new Stuff("Code");
our @links; our $ln = 0;
our $G = new Stuff("Nothing");
our $root = $G;
our @entropy_fields = ($root);
sub entropy_increases {
    die "too many entropy fields" if @entropy_fields > 10;
    $_->{at_maximum_entropy} = 0 for @entropy_fields;
}
sub get_linked_object_by_memory_address {
    my $id = shift;
    for my $l (@links) {
        for (0, 1) {
            return $l->{$_} if "$l->{$_}" =~ /\Q$id\E/;
        }
    }
    for my $o (@findable_objects) {
        return $o if "$o" =~ /\Q$id\E/
            || ref $o eq "Node" && "$o->{thing}" =~ /\Q$id\E/;
    }
}
=pod ENTROPY FIELD
each link is in one field.
things can be in multiple fields by many links.
field A thing links to field B thing, link is field A, &? hook.
search doesn't cross fields unless demanded.

fields defined by patterns, including the meanderer '...' which is like
a wildcard... goes off in all directions, in the current field.

dumper prettyprints meanders

this could be displayed as a goo smothered graph while foreign
looking junk looks foreign.
the interfaces from one field to another must be defined, then,
to allow them to be useful to each other and not spread indefinitely.

upon ->link, which is represented in graph in the callstack field,
patterns can be used to behave good with:
 - linking into $code orbitals, instantiating the $code object in
   the linkees field
also most fields will want to hide themselves from search() unless
explicitly spec'd somehow.
=cut 
#}}}

my @modules = (
"Intuitor",
#"Scap2Blog",
);
sub do_stuff {
    for (@modules) {
        say "loading $_...";
        require "$_.pl";
    }
    start_timer();
    my $clicks = 0;
    until ($root->{at_maximum_entropy} || $clicks++ > 21) {
        $root->{at_maximum_entropy} = 1;
        $clicks++ && say "\nclick!\n";
        process({Linked => $wants});
        last
    }
    say "$clicks clicks in ". show_delta();
}



$code->spawn(
[ "Click", be => sub { process({Linked => $wants}) } ],
[ "Linked", be => sub { 
    transmog($G => $G->In->{it}->[0]->linked) } ],
#[ "Flow", be => sub { $G->{be}->($G) } ],
);

my $patterns = new Stuff("Patterns"); #{{{
$patterns->link(
    $patterns->{on_evap} = new Pattern(spec => "(proc)->Evaporation") );
$patterns->link(
    $patterns->{on_exec} = new Pattern(spec => "(proc)->Execution") );
sub on_evaporation_flow {
    $patterns->{on_evap}->link(new Flow(@_));
}
sub on_execution_flow {
    $patterns->{on_exec}->link(new Flow(@_));
}
on_evaporation_flow(
    name => "Apply Codes in Evaporation",
    be => sub {
        for my $c ($code->linked) {
            my $o = ref $c;
            for my $in ($G->linked("In")) {
                if ($in->{it}->[0] eq $o) {
                    my @new_in = @{ $in->{it} };
                    shift @new_in;
                    if (@new_in) {
# TODO this code needs to be instantiated somehow from the "factory" in
# orbit around $code. $code has it's own entropy field since it's abstract
# intellect for plucking out into arrangements.
# so when a code gets linked, we instead put a clone of it outside $code's
# orbit, transparently that one is linked to instead.
                        $c->spawn("In", it => \@new_in);
                    }
                    $G->unlink($in);
                    $G->link($c);
                }
            }
        }
    },
);
on_evaporation_flow(
    name => "Make Instructions from what Flows want",
    be => sub {
        for my $f ($G->linked("Flow")) {
            next unless $f->{want};
            next if $f->linked("In");
# make an entropy field for what this Flow consumes? the In's stick around,
# and don't get update (if it mattered). perhaps the field I speak of here
# is another concept close by...
            my @junk = grep { $f->{want}->match($_) } $junk->linked;
            unless (@junk) {
                say "Flow ".summarise($f)." nothing wanted found";
                next;
            }
            for my $j (@junk) {
                $f->spawn("In", it => $j);
            }
        }
    },
);
on_execution_flow(
    name => "Be Codes",
    be => sub {
        travel($G, { everywhere =>
            sub { 
                if ($G->linked($code)) {
                    my $t = main::trace("Being the code $G");
                    say "  Being the code $G";
                    $G->{be}->();
                    $t->D;
                }
            },
        });
    },
);
on_execution_flow(
    name => "Be Flows",
    be => sub {
        for my $w ($G->linked("Flow")) {
            $w->{be}->($w)
        }

    },
);
#}}}

my @flows_in_progress;

sub patterner { # {{{
    my %p = @_;
    $DB::single = 1 if $p{new_link}->{1} =~ /Tracer/;
    my $t = main::trace("patterner", \%p);
    $t->D, return unless $patterns;

    my $pat_by_o = $patterns->{by_o} ||= {};
    my $in_progress = $patterns->{in_progress} ||= {};

    if (my $l = $p{new_link}) {
        if (my $ol = order_link($patterns, $l)) {
            my $p = $ol->{1};
            my $t = main::trace("link new pattern", $p);
            my @objects = spec_objects($p);
            for my $o (@objects) {
                my $ops = $pat_by_o->{$o} ||= [];
                push @$ops, $p;
            }
            $t->D;
            #say "Pattern linked as @objects";
        }
        elsif (my $oll = order_link("Pattern", $l)) {
            #say "Linking to patterns: ".Dump($l);
            #$patterns->link($oll->{0});
            my $t = main::trace("pattern out there", $oll->{0});
            main::trace("Pattern links to $oll->{1}")->D
                if spec_comp("!Flow" => $oll->{1});
            $t->D;
        }
        else {
            # try and complete patterns related to either object
            my @tryable = uniq map { @{$pat_by_o->{$_}||[]} }
                map { ref $_ } $l->{0}, $l->{1};
            
            for my $p (@tryable) {
                # about here... look up progressed matches and resume
                my $progress = $in_progress->{"$p"} ||= [];
                # feed the progress if any to search, continue from there
                #   it'll need the tree of nodes it came through
                #   the spec up to the point
                # if it finishes keep all the branches I guess?
                #   then we'd have all these patterns and all their matches
                # 
                my $t = main::trace('trying pattern', $p, $progress);
                my @matching = search($p->{spec});
                $t->D, next unless @matching;
                my @flows = $p->linked("Flow"); #{{{
                $t->D, main::trace("no flows on $p")->D, next unless @flows;
                my @call_set;
                for my $r (@matching) {
                    for my $f (@flows) {
                        my $sig = "$r $f";
                        if (grep { $sig eq $_ } @flows_in_progress) {
                            main::trace("Going to avoid recursing $p->{spec} $sig")->D;
                            next;
                        }
                        push @call_set, [ $r, $f ];
                    }
                }
                my $call_set_n = @call_set;
                push @flows_in_progress, map { "$_->[0] $_->[1]" } @call_set;
                for (@call_set) {
                    $G = $_->[0];
                    my $f = $_->[1];
                    my $t = main::trace("calling Flow: $f->{name}");
                    $f->{be}->($f);
                    $t->D;
                }
                $t->D;
                pop @flows_in_progress for $call_set_n;
            }
        } # }}}
    }
    else {
        die
    }
    $t->D;
} # }}}
# {{{
# Evaporation and Execution is pattern-based, see $patterns
# Instruction = (Linked => $wants)
# string matches In's "Linked"
# $wants becomes a new Instruction = ($wants)
# entropy maxed, Linked executes:
# pulls in its Instruction, returns linked $wants (the Flows)
# replaces itself with them via transmog()
# Flows get executed

# Evaporation and Execution and proc are candidates for
# a new architecture based around entropy fields
# which are like domains of graph that won't implicitly
# get mixed up with everything.
# like having a nice callstack tracking graph.
# or just avoiding infinite loops when we're waiting for nothing
# to change while we create and destroy a link to set off pattern matches.
sub process {
    my $d = shift;
    my $here = $G;
# ready() does patterny preparations without executing anything
# takes datastructure and makes it into graph objects by
# turning datastructure into an Instruction
# then whateverses match the Instruction by sheer digital willpower...

    my $proc = $G = $here->spawn("proc");
    my $t = main::trace("process", $d, $proc);
    local @entropy_fields = (@entropy_fields, $proc);
    ready($d);
    displo($here);
    EVAPORATE: until ($proc->{at_maximum_entropy}) {
        $proc->{at_maximum_entropy} = 1;

        say "EVAPORATING";
        my $evap = $proc->spawn("Evaporation");
        my $t = main::trace("Evap", $evap);
        $proc->unlink($evap);
        $t->D;

    }
    say "READY!";
    $proc->{at_maximum_entropy} = 0;
    EXECUTE: until ($proc->{at_maximum_entropy}) {
        $proc->{at_maximum_entropy} = 1;

        say "EXECUTING";
        my $exec = $proc->spawn("Execution");
        my $t = main::trace("Exec", $exec);
        $proc->unlink($exec);
        $t->D;

        unless ($proc->{at_maximum_entropy}) {
            say "RUN - GOING BACK TO EVAPORATE";
            goto EVAPORATE;
        }
    }
    $t->D;
    say "IS DONE!";
    #displo($here);
}

sub transmog {
    my ($going, @coming) = @_;
    my $proc = $going->linked("proc");
    my $t = main::trace("transmog", $proc, $going, \@coming);
    $proc->unlink($going);
    for my $c (@coming) {
        $proc->link($c);
        $c->link($going, "replaces");
    }
    $t->D;
}

sub ready {
    my $d = shift;
    my $t = main::trace("ready");
    if (ref $d eq "ARRAY") {
        $G->spawn("In", it => $d);
        say "Jhurtiiz: ".Dump($G);
        die;
    }
    elsif (ref $d eq "HASH") {
        while (my ($k, $v) = each %$d) {
            $G->spawn("In", it => [$k, $v]);
        }
    }
    else {
        $G->spawn("In", it => [$d]);
    }
    $t->D;
}
# }}}

sub getlinks {
    my %p = @_;

    local @main::links = @{$p{from}->graph->{links}}
        if $p{from} && ref $p{from} eq "Node";
    local @main::links = @{$p{to}->graph->{links}}
        if $p{to} && ref $p{to} eq "Node";

    my @links = @links;
    @links = map { main::order_link($p{from}, $_) } @links if $p{from};
    @links = grep { main::spec_comp($p{to}, $_) } @links if $p{to};

    main::trace("getlinks", \%p, scalar(@links))->D;

    return @links;
}

# the thing that's constantly watching the graph evolve and tracking
# pattern matches needs to be able to take a transient limb at any
# point, as well as being drip fed, so Stuff code can have hooks,
# eg, on link, unlink, you name it.
# hyperreal code. it should know about callstack interrogation for
# the debug toolchain fantasy.

# the whole thing can be composed of probably a dozen algorithms
# glued together with the right names.
# Flows are just CODE for now but in the future they could be graphs
# of algorithms, graphs of input and output specs, etc.
# these seem like information about branches of the task of building a tree.
# all to do with travel() and things poking it with closures.
# spec could eventually understand the whole stick:
# Flow@-{want-} @-> $junk@->match(${want}) && In<-(${junk}) be(${Flow}) )
# foreach Flow, foreach junk linked where match $want, be Flow with junk
sub search { # {{{
    my %p;
    my $t = main::trace("search", @_);
    $p{spec} = shift if @_ == 1;
    %p = @_ if @_ > 1;

    my @spec = parse_spec($p{spec});
    if ($p{start_from}) {
        unshift @spec, { object => $p{start_from} };
    }

    my $get_first_column = sub {
        my $spec = shift;
        return uniq map { $_->{0} } getlinks(from => $spec)
    };

    my @cols;
    my $results = {};
    my $by_parent = {};
    my $take_result = sub {
        my $l = shift;
        # parent being the previous column
        if ($l) {
            push @{$by_parent->{"$l->{0}"} ||= []}, $l;
            $results->{"$l"} = $l;
        }
    };

# {{{
#    for my $fr (@first_column) {
# travel from $fr through spec, into $take_result...
#                my ($l, $ex, $G) = shift;
#                if (main::spec_comp($ex->{spec}->[$ex->{depth}], $l)) {
#                    $take_result->($l->{1}, $G

    my @first_column;
    my $results2tuples = sub {
        my @tuples;
        if (my $travelled_cols = @spec - 1) {
            my $interro;
            $interro = sub {
                my ($parent_id, $depth, @tuple) = @_;
                $depth--;
                if ($depth < 0) {
                    # reached the end
                    push @tuples, \@tuple;
                    return 1;
                }
                if (my $children = $by_parent->{$parent_id}) {
                    my @c_fails;
                    # see if later on the trail dries up
                    for my $c (@$children) {
                        my $parent_id = $c->{1};
                        $interro->($parent_id, $depth, (@tuple, $c))
                            || push @c_fails, 1;
                    }
                    if (@c_fails == @$children) {
                        delete $by_parent->{$parent_id};
                        return 0;
                    }
                    else {
                        # results as graph? too hard.
                    }
                }
                else {
                    return 0;
                }
            };
            for my $fr (@first_column) {
                $interro->("$fr", $travelled_cols, ($fr));
            }
        }
        else {
            die "spec was just 1 thing (this is a test)";
            @tuples = \@first_column;
        } #}}}
        return \@tuples
    };
    
    @first_column = $get_first_column->($spec[0]->{object});
    my @last_column = @first_column;
    my ($first_specsicle, @travelling_spec) = @spec;
    for my $s (@travelling_spec) {
        my @froms = @last_column;
        @last_column = ();
        for my $from (@froms) {
            my @links = getlinks(from => $from, to => $s->{object});
            for my $l (@links) {
                push @last_column, $l->{1};
                $take_result->($l);
            }
        }
    }

    my $tups = $results2tuples->();

    my @return;
    if (my @col_ns = grep { $spec[$_]->{return} } 0..@spec-1) {
        for my $row (@$tups) {
            my @cols = map { $row->[$_] } @col_ns;
            push @return, \@cols;
        }
        if (@col_ns == 1) {
            @return = @{$return[0]} if $return[0];
        }
    }
    else {
        @return = map { $_->[-1] } @$tups
    }
    #say "Hmm: ". join"  ", map { $_->{object} } @spec;
    #say Dump([ \@return ]) if $yeah;

    $t->D;
    return @return
}

sub parse_spec { #{{{
    my $spec = shift;
    if (!defined $spec) {
        $spec = "*"
    }
    if (ref $spec) {
        return { object => $spec }
    }
    my @spec = split /(?<=->)/, $spec;
    my $chunk = sub {
        $_ = shift;
        my $i = {};
        ($i->{arrow} = s/->$//)
            || s/-$//;
        $i->{return} = s/^\((\w+)\)$/$1/;
        /^(!?\w+|\*)$/ || die "$_ noparse object!";
        $i->{object} = $1;
        return $i
    };
    return map { $chunk->($_) } @spec
}
sub spec_objects {
    my $p = shift;
    die unless ref $p eq "Pattern";
    return uniq map { $_->{object} } parse_spec($p->{spec});
}
#}}}

=pod
travel is to channel graph interrogations
with logic about fields (not going into $code or transmogs)

=cut
sub hook {
    my ($ex, $hook) = (shift, shift);
    return unless exists $ex->{$hook};
    $ex->{$hook}->($G, $ex, @_);
}
sub travel { # TRAVEL
    $G = shift || $G;
    my $ex = shift if ref $_[0] eq "HASH";
    $ex ||= {};
    unless ($ex->{seen_oids}) {
        $ex->{depth} = 0;
        $ex->{seen_oids} = {};
        $ex->{via_link} = -1;
    }
    hook($ex, "everywhere");

    if ($ex->{depth} > 500) {
        die "DEEP RECURSION!";
    }

    my @links = getlinks(from => $G);
    hook($ex, "all_links", \@links);

    @links = grep { $_ ne $ex->{via_link} } @links;
    hook($ex, "forward_links", \@links);

    @links = grep { ! exists $ex->{seen_oids}->{"$_->{1}"} } @links;
    hook($ex, "new_links", \@links);

    $ex->{seen_oids}->{"$G"} ||= { summarise($G) => [] }; #\@links };

    die if grep { $G ne $_->{0} } @links;
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
        travel($l->{1}, $ex)
    }
}

sub spec_comp {
    my $spec = shift;
    my $thing = shift;
    my $l;
    if (ref $thing eq "HASH") {
        $l = $thing;
        $thing = $l->{1};
    }

    if ($spec =~ /^l\((\w+)\)$/) {
        my $linkval = $1;
        say "$linkval vs $l->{val}->[0]";
        return 1 if $l->{val}->[0] eq $linkval;
        return 0
    }

    return 1 if $spec && $spec eq "*";
    my $not = $spec =~ s/^!//;
    my $r = ref $spec   ? $thing eq $spec      # an object
            : $spec     ? ref $thing eq $spec  # package name
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
            val => $l->{val}, id => $l->{id}
        }
    }
    return ()    
}
sub delete_link {
    my $l = shift;
    my $id = $l->{id};
    my $i = 0;
    for ($i..@links-1) {
        if ($links[$i]->{id} eq $id) {
            splice @links, $i, 1;
            return;
        }
        $i++;
    }
    die "no such link (to delete) $l->{id}"
}
# }}}

{ package Stuff;
# base class for all things in this metaverse
# link  links stuff together
# links returns all links
# {{{
use List::MoreUtils 'uniq';
sub new {
    shift if $_[0] eq "Stuff";
    my $package = __PACKAGE__;

    if ($_[0]) {
        $package = shift;
        my $base = $_[0] && ref $_[0] eq "HASH" && $_[0]->{base} && shift(@_)->{base} || "Stuff";
        eval "package $package; use base '$base';";
        die $@ if $@;
    }
    my $self = bless {@_}, $package;
    if (my $ls = delete $self->{link}) {
        $self->link($_) for ::tup($ls)
    }
    return $self;
}
sub TO_JSON {
    my $self = shift;
    return "$self: ".join(" ",%$self);
}
sub spawn {
    my $self = shift;
    if (ref $_[0] eq "ARRAY") {
        $self->spawn(@$_) for @_;
    }
    else {
        my $new = new Stuff(@_);
        $self->link($new);
        return $new
    }
}
sub In { #TODO
    my $self = shift;
    my $in = $self->linked("In") || die;
    return $in
}
sub link {
    my ($I, $II, @val) = @_;
    $I && $II && $I ne $II || die "linkybusiness";
    my $l = {
        0 => $I, 1 => $II,
        val => \@val, id => $main::ln++,
    };

    # TODO field attachment
    main::linkery($l);
    main::entropy_increases()
        unless main::order_link("Evaporation", $l)
            || main::order_link("Execution", $l);
    push @links, $l;
    ::patterner( new_link => $l );
    return $_[0]
}
sub unlink {
    say "unlinking @_";
    my $self = shift;
    my $other = shift;
    my @ls = $self->links($other);
    $main::ln++;
    for my $l (@ls) {
        main::entropy_increases()
            unless main::order_link("Evaporation", $l)
                || main::order_link("Execution", $l);
        main::delete_link($l);
    }
}
sub linked {
    my $self = shift;
    my $spec = shift;

    my @linked = uniq map { $_->{1} } $self->links($spec);
    wantarray ? @linked : shift @linked
}
sub links {
    my $self = shift;
    my $spec = shift;
    if (!$spec) {
        return main::getlinks(from => $self);
    }
    return main::search(
        start_from => $self,
        spec => $spec,
    );
}
} {
package Transducer;
use base 'Stuff';
sub new {
    shift; # 'Transducer'
    my $self = Stuff::new(shift, {base=>"Transducer"}, @_);
    $self->{name} ||= ref $self;
    $self
}
sub do {
    my $self = shift;
    # make @_ findable and then be

}
}
{ package Text;
# uhm...
use base 'Stuff';
sub new { shift; bless { text => shift }, __PACKAGE__; }
sub text {
    shift->{text}
}
} # }}}
{ package Pattern;
# new(names => @names) # primitive pattern matching
# are linked to $matches
# {{{
use base 'Stuff';
sub new {
    shift;
    my $self = bless {@_}, __PACKAGE__; # names => @names
    die if $self->{names} && grep { $_ eq "string" } @{$self->{names}};
    $self;
}
sub match {
    my $self = shift;
    my $it = shift;

    # TODO some logicator from cpan?
    if ($self->{object} && !$self->{names}) {
        my $res = ref $it eq $self->{object};
        # say "match ".($res?"PASS":"FAIL").": string";
        $res
    }
    elsif ($self->{names}) {
        my %res;
        my %objects = map {$_->{1}->{name} => $_->{val}->[0]} $it->links($self->{object});
        for my $name (@{$self->{names}}) {
            $res{$name} = (defined $objects{$name} && $objects{$name} == 1);
        }
        my $res = (0 == grep { $res{$_} == 0 } keys %res);
        # say "match ".($res?"PASS":"FAIL").": ". join "\t", %res;
        $res;
    } else {
        say "Pattern unmatchable: $self";
        say Dump($self);
        $DB::single = 1;
        say "BLAC!"
    }
}
} # $}}}
{ package Flow;
# new
# {{{
use base 'Stuff';
sub new {
    shift;
    my $self = bless { @_ }, __PACKAGE__;
    if ($self->{want}) {
        $wants->link($self);
    }
    return $self
}
}
# }}}

do_stuff() unless caller;

sub sum { # {{{
    my $thing = shift;
    my $text = "$thing";
    if (ref $thing eq "Flow") {
        $text =~ s/HASH\(0x/$thing->{name}(/;
    }
    return $text
}
sub summarise {
    my $thing = shift;
    my ($text, $id, $color);
    if ($thing =~ /^\w+$/) {
        $id = "???",
        $text = "'$thing'";
        $color = "000";
        return $thing;
    }
    ($id) = $thing =~ /\((.+)\)/ or moan "summarise not a ref!? $thing";
    ($color) = $id =~ /(...)$/;
    $color ||= "000";
    given (ref $thing) {
        when ("If") {
            $text = "If expr=".($_[0]->{EXPR}||"")
        }
        when ("In") {
            $text = "In-".join" ",tup($_[0]->{it})
        }
        when ("Text") {
            $text = "$thing: ".$thing->text;
        }
        when ("Intuition") {
            if (my $val = shift) {
                $text = join "\t", "Intuition",
                    join(" ",
                        map { $_ eq "" ? '""' : $_ }
                        map { !defined($_) ? " " : $_ }
                        tup($val)
                    ),
                    "$thing->{cer} $thing->{name}",
                    ref $thing->{cog} eq "Regexp" ? "$thing->{cog}" : (),
            }
            else {
                $text = "$thing: $thing->{cer} $thing->{name} $thing->{cog}"
            }
        }
        when ("Intuit") {
            $text = "$thing: wants: ".summarise($thing->{want});
        }
        when ("Pattern") {
            $text = "$thing: object=$thing->{object} ".
                ($thing->{names} ? join("+",@{$thing->{names}}):"");
        }
        when ("BunchOfCode") {
            $text = "BunchOfCode $thing->{called}";
        }
        when ("In") {
            $text = "Instruction ".tup($thing->{it});
        }
        when ("Node") {
            $text = "Node ".summarise($thing->{thing});
        }
        when ("Tracer") {
            my @bits = map {
                ref $_ && (ref $_ eq "HASH" || ref $_ eq "ARRAY") ?
                    $json->encode($_)
                  : "$_"
            } @{$_[0]->{val}};
            $text = "Tracer: ".join "   ", @bits;
        }
        when ("HASH") {
            $text = encode_json($thing);
        }
    }
    $text ||= "$thing";
    return $text;
    return sprintf '<li id="%s" style="background-color: #%s">%s</li>', $id, $color, $text, $id;
}

sub link2text {
    my $l = shift;
    "$l->{1}" =~ /^(\w+)/;
    my $name = $1;
    # TODO should display like link val query syntax, to be formulated
    my $val = join " ", map { $_ ||= "undef"; $_ } tup($l->{val}), $name;
    return $val
};
sub links_by_id {
    map { 
        $_->{id} => {
            %$_,
            text => link2text($_),
        }
    } @_;
};
sub links_by_other_type {
    my %links = @_;
    my %by_other;
    for my $l (values %links) {
        my $type = ref $l->{1};
        push @{$by_other{$type}||=[]}, $l;
    }
    %by_other;
};# }}}

my %seen_oids;
my $n= 0;
sub assplain { # {{{
    my ($thing, $previous_lid) = @_;

    my $tree = [];
    unless ($previous_lid) { # start
        $previous_lid = -1;
        push @$tree, summarise($thing);
    }

    my $figure_link = sub {
        my ($l, $ob, $prev) = @_;
        my $o = $l->{1};

        if (!defined $o) {
            warn "undef link: $l->{id}";
            return "UNDEFINED!"
        }
        if ($n++ > 2000) {
            return "DEEP RECURSION!"
        }

        my ($linkstash) = values %$ob;

        if ($o eq $code) {
            @$linkstash = ("Code...");
        }
        elsif (!$prev) {
            my $connective = assplain($l->{1}, $l->{id});
            push @$linkstash, @$connective;
        }

        return $ob;
    };

    my %links = links_by_id($thing->links);
    my %by_other = links_by_other_type(%links);
    my %prev;
    for my $k (sort keys %by_other) {
        for my $l (@{$by_other{$k}}) {
            next if $l->{id} eq $previous_lid;

            my $o = $l->{1};
            my $oid = "$o";
            $prev{$oid} = exists $seen_oids{$oid};
            $seen_oids{$oid} ||= { summarise($o) => [] };
        }
    }
    for my $k (sort keys %by_other) {
        for my $l (@{$by_other{$k}}) {
            next if $l->{id} eq $previous_lid;

            my $o = $l->{1};
            my $oid = "$o";
            my $fig = $figure_link->($l, $seen_oids{$oid}, $prev{$oid});

            next unless $fig;
            push @$tree, { $l->{text}, $fig };
        }
    }

    return $tree;
}

sub tup {
    my $tuple = shift;
    ref $tuple eq "ARRAY" ? @$tuple : $tuple;
}

sub displo {
    for (@_) {
        %seen_oids = ();
        $n = 0;
        my $g = assplain($_);
        my @lines = grep { /\w/ } split "\n", Dump($g);
        say "\n". join "\n", @lines;
    }
}#}}}


sub displow {
    my $object = shift;
    my $ex = shift || {};
    my @lines;
    $ex->{everywhere} = sub {
        my ($G, $ex) = @_;
        push @lines,
            join("", (" " x $ex->{depth}))
            .summarise($G)
    };
    travel($object, $ex);
    return join "\n", @lines;
} # }}}

our $whereto = ["boxen", {}];
#$whereto = [object => { id => "Text" }];

our $webbery = new Graph('webbery');
$webbery->spawn("clients");
$webbery->{when_link} = sub { # this is a unique-or-delete-other
    my ($self, $l) = @_;
    return unless $l->{0}->{thing} eq "clients";
    say "clearing up...";
    my $new_client = $l->{1};
    my @client_nodes = $webbery->find("clients")->linked();
    my @our_old_client =
        grep { $l->{1} ne $_ }
        grep { $new_client->{thing} eq $_->{thing} } @client_nodes;
    die "morenone" if @our_old_client > 1;
    $our_old_client[0]->trash(":session") if @our_old_client;

    $new_client->field(":session");
};

use Mojolicious::Lite;
get '/hello' => sub {
    my $self = shift;
    $webbery->find("clients")->spawn("the"); # cleans/sets things up with when_link ^
    $no_more_tracery = 1;
    $self->render(json => $whereto);
};
get '/stats' => sub {
    my $self = shift;
    $self->drawings(
        ["status", thestatus()]
    );
};
sub thestatus { "There are ".scalar(@main::links)." links" }

get '/boxen' => sub {
    my $self = shift;
    $self->drawings(
        ["clear"],
        ["status", thestatus()],
        @boxen,
        map {
            say "making $_->{thing} findable..";
            my ($name, $id, $color) = "$_->{thing}" =~ m{^(\w+)=.+\((0x...(...).)\)$};
            $name = "$name $id";
            ["boxen", 500, 20, 30, 30,
                { fill => $color, name => $name, id => $id } ]
        } @findable_objects
    );
};

get '/object' => sub {
    my $self = shift;
    my $id = $self->param('id');
    my @timings;
    push @timings, "start: ".show_delta();
    say "ID ID ID $id";
    say "@findable_objects";
    die "no id" unless $id;
    my $object = get_linked_object_by_memory_address($id);
    unless ($object) {
        return $self->sttus("$id no longer exists!");
    }

    # find the VIEWED graph: existing subset and svg info
    # "the" == unique identifier per /hello (per browse)
    my @us = grep { $_->{thing} eq "the" } $webbery->find("clients")->linked();
    die "client fuckery" if @us != 1;
    my ($us) = @us;
    my @viewed = grep { ref $_->{thing} eq "Graph"
                        && $_->{thing}->{name} eq "object-examination" } $us->linked();
    die "hu1" if @viewed > 1;
    my ($viewed) = @viewed;
    $viewed = $viewed->thing if $viewed;

    if ($viewed && $viewed->first->thing."" eq $object) {
        return $self->sttus("same diff");
    }


    my (@drawings, @animations, @removals);


    # TODO this is a travel()/search() result-as-graph idea
    my $exam = $us->spawn(Graph->new('object-examination'));
    $exam = $exam->{thing};

    my $trav = Travel->new(ignore =>
        ["->{no_of_links}", "->{iggy}", "nonref"]);

    my $head;
    $trav->travel($object, sub {
        my ($G, $ex) = @_;
        if ($ex->{previous}) {
            my $found = $exam
                ->find($ex->{previous});
            $found
                ->spawn($G, $ex->{via_link});
        }
        else {
            $head = $exam->spawn($G);
        }
    });


    # Just an exercise, we can do this more casually in the svg build
    $trav->travel($head,
        all_links => sub {
            $_[0]->spawn({no_of_links => scalar @{$_[2]}})
        },
    );

    my $new_svg = $exam->spawn("svg");

    my $nameidcolor = sub {
        my $summarised = shift;
        if ($summarised =~
            m{^(?:Node )?\s*([\w -]+)=.+\((0x...(...).)\)}) {
            my ($name, $id, $color) = ($1, $2, $3);
            $name = "$name $id";
            return ($name, $id, $color);
        }
        else {
            return ("$summarised", "???", "000");
        }
    };

    push @timings, "got examined subset: ".show_delta();

    my ($ids) = grep { ref $_->{thing} eq "HASH"
        && $_->{thing}->{ids} } $us->linked;
    $ids ||= do { $us->spawn({ids => {}})->{ids} };

    my ($x, $y) = (30, 40);

    $trav->travel($head, sub {
        my ($G, $ex) = @_;
        my $x = $x + $ex->{depth} * 20;
        $y += 20;
        my $stuff = summarise($G);

        my ($linknode) = grep { ref $_->thing eq "HASH"
            && $_->thing->{no_of_links} } $G->linked;
        my $no_of_links = $linknode->thing->{no_of_links}
            if $linknode;

        my ($name, $id, $color) = $nameidcolor->($stuff);
        my $oxble_uniq = uniquify_id($ids, "${id}oxble");
        $ids->{$oxble_uniq} = undef;
        my $settings = sub {
            my $kind = shift;
            my $settings = { fill => $color, id => $id,
                class => "$oxble_uniq $color $id", name => $name };
            return $settings;
        };

        my $box_set = $settings->("boxen");
        $new_svg->link($G,
            [ "boxen", $x-20, $y-2, 18, 18, $box_set ]
        );

        my $lab_set = $settings->("label");
        delete $lab_set->{fill};
        if ($no_of_links && $no_of_links > 1) {
            $lab_set->{'font-weight'} = "bold";
        }
        $new_svg->link($G,
            [ "label", $x, $y, $stuff, $lab_set]
        );
    });
    
    push @timings, "linked svg: ".show_delta();

    my $preserve = $exam->spawn("preserve");
    my $old_svg = $viewed->find("svg") if $viewed;
    $trav->travel($head, sub {
        my ($new, $ex) = @_;
        my @old = $viewed->find($new->thing) if $viewed;
        my ($old) = grep { !$_->linked($preserve) } @old;
        if ($old) {
            $preserve->link($old);
     
            my @olds = map { $_->{val}->[0] } $old->links($old_svg);
            die "hmm" if @olds != 2;
            my @news = map { $_->{val}->[0] } $new->links($new_svg);
            die "har" if @news != 2;

            my ($oxble_uniq) = split /\s/, $olds[0]->[-1]->{class};

            my $bits;
            for ([old => @olds], [new => @news]) {
                my ($e, @d) = @$_;
                for my $ds (@d) {
                    $bits->{$e}->{$ds->[0]} = $ds;
                }
            }

=pod
when we call translate() on it the second time in the next request it
moves the thing from where it was before translate() in this request...
it doesn't MOVE things, it just translates... wish I had more docs offline
=cut

            my $diffs;
            for my $t ("label", "boxen") {
                $diffs->{$t}->{x} =
                    ($bits->{new}->{$t}->[1]
                   - $bits->{old}->{$t}->[1]);
                $diffs->{$t}->{y} =
                    ($bits->{new}->{$t}->[2]
                   - $bits->{old}->{$t}->[2]);
            }
            die "divorcing boxen-labels" unless
                $diffs->{label}->{x} == $diffs->{boxen}->{x}
                && $diffs->{label}->{y} == $diffs->{boxen}->{y};
            my $trans = $diffs->{label}->{x}." ".$diffs->{boxen}->{y};
            if ($diffs->{label}->{x} != 0 ||
                $diffs->{boxen}->{y} != 0) {
                push @animations, ["animate", $oxble_uniq,
                        {svgTransform => "translate($trans)"},
                    300];
            }
        }
        else {
            push @drawings,
                map { $_->{val}->[0] } # new: label, boxen
                $new_svg->links($new);
        }
    });
    if ($viewed) {
        $trav->travel($viewed->first, sub {
            my ($G,$ex) = @_;
            unless ($preserve->links($exam->find($G))) {
                my $sum = summarise($G);
                my @tup = $nameidcolor->($sum);
                my $id = $tup[1];
                push @removals, ["remove", $id ];
            }
        });
    }
    
    push @timings, "diffed svg: ".show_delta();
    
    my $clear;
    unless ($viewed) {
        $clear = 1;
    }
    else {
        $viewed->DESTROY(); # can't translate() twice so trash it
    }

    @drawings = (@removals, @animations, @drawings);

    push @timings, "enzot: ".show_delta();
    unshift @drawings, 
        ["status", "For ". Dump($object) ." ". join(" ... ", @timings)];
    unshift @drawings, ["clear"] if $clear;
    $self->drawings(@drawings);
};

get '/object_info' => sub {
    my $self = shift;
    $self->render("404");
};

get '/' => 'index';
*Mojolicious::Controller::drawings = sub {
    my $self = shift;
    $self->render(json => \@_);
};
*Mojolicious::Controller::sttus = sub {
    my $self = shift;
    $self->drawings(["status", shift]);
};

return 1 if caller;
use Mojo::Server::Daemon;
my $daemon = Mojo::Server::Daemon->new;
$daemon->listen(['http://*:3000']);
$daemon->run;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>scap!</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <style type="text/css">@import "jquery.svg.css";</style>
    <script type="text/javascript" src="jquery.svg.js"></script>
    <script type="text/javascript" src="jquery.svganim.js"></script>
    <script type="text/javascript" src="scope.js"></script></head>
    <body style="background: #897">
    <div id="view" style="background: #fff"></div>
    </body>
</html>

