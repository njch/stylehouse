#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

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
    push @boxen, [boxen => @$p, 18, 18, @$child ];
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
want to figure out why classing box + label pairs like 0x9299e08lb
makes them impossible to find. even if you inspect the element you can
see class="0x9299e08lb, 9e0, 0x9299e08", but searching for it finds nothing.
I guess I should take off the 0x... though 0x12 doesn't find 18

anyway...
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
    my $l = {
        0 => $I, 1 => $II,
        val => \@val,
    };
    push @{$self->{links}}, $l;
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
sub spawn {
    my $self = shift;
    my $spawn = $self->graph->spawn(shift);
    $self->link($spawn, @_);
    return $spawn;
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
                    && $_[0]->{1}->thing->{$k} }
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
    main::travel($main::G, $ex);
}
        

package main;

my $tracery = new Graph ("tracery");

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
            return $l->{$_} if "$l->{$_}" =~ $id;
        }
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

my $dumpstruction = new Stuff("DS"); #{{{
use JSON::XS;
$dumpstruction->spawn(
[ "If", be => sub { "If expr=".($_[0]->{EXPR}||"") } ],
[ "In", be => sub { "In-".join" ",tup($_[0]->{it}) } ],
);
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
                    say "  Being the code $G";
                    $G->{be}->()
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
    return unless $patterns;

    my $pat_by_o = $patterns->{by_o} ||= {};
    my $in_progress = $patterns->{in_progress} ||= {};

    if (my $l = $p{new_link}) {
        if (my $ol = order_link($patterns, $l)) {
            my $p = $ol->{1};
            my @objects = spec_objects($p);
            for my $o (@objects) {
                my $ops = $pat_by_o->{$o} ||= [];
                push @$ops, $p;
            }
            #say "Pattern linked as @objects";
        }
        elsif (my $oll = order_link("Pattern", $l)) {
            #say "Linking to patterns: ".Dump($l);
            #$patterns->link($oll->{0});
            say "Pattern links to $oll->{1}"
                if spec_comp("!Flow" => $oll->{1});
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

                my @matching = search($p->{spec});
                next unless @matching;
                my @flows = $p->linked("Flow"); #{{{
                say("no flows on $p"), next unless @flows;
                my @call_set;
                for my $r (@matching) {
                    for my $f (@flows) {
                        my $sig = "$r $f";
                        if (grep { $sig eq $_ } @flows_in_progress) {
                            say "Going to avoid recursing $p->{spec} $sig";
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
                    say "calling Flow: $f->{name}";
                    $f->{be}->($f);
                    say "OUT!";
                }
                pop @flows_in_progress for $call_set_n;
            }
        } # }}}
    }
    else {
        die
    }
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
    local @entropy_fields = (@entropy_fields, $proc);
    ready($d);
    displo($here);
    EVAPORATE: until ($proc->{at_maximum_entropy}) {
        $proc->{at_maximum_entropy} = 1;

        say "EVAPORATING";
        my $evap = $proc->spawn("Evaporation");
        $proc->unlink($evap);

    }
    say "READY!";
    $proc->{at_maximum_entropy} = 0;
    EXECUTE: until ($proc->{at_maximum_entropy}) {
        $proc->{at_maximum_entropy} = 1;

        say "EXECUTING";
        my $exec = $proc->spawn("Execution");
        $proc->unlink($exec);

        unless ($proc->{at_maximum_entropy}) {
            say "RUN - GOING BACK TO EVAPORATE";
            goto EVAPORATE;
        }
    }
    say "IS DONE!";
    #displo($here);
}

sub transmog {
    my ($going, @coming) = @_;
    my $proc = $going->linked("proc");
    $proc->unlink($going);
    for my $c (@coming) {
        $proc->link($c);
        $c->link($going, "replaces");
    }
}

sub ready {
    my $d = shift;
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
    my $text;
    my ($id) = $thing =~ /\((.+)\)/ or moan "summarise not a ref!?";
    my ($color) = $id =~ /(...)$/;
    if (my ($inst) = $dumpstruction->linked(ref $thing)) {
        $text = $inst->{be}->($thing);
    }
    else {
    given (ref $thing) {
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
        when ("HASH") {
            $text = encode_json($thing);
        }
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
$whereto = [object => { id => "Text" }];
our $viewed;
our $old_svg;
sub hello {
    my $self = shift;
    undef $viewed;
    $old_svg = {iggy => "the guana"};
    $self->render(json => $whereto);
}
sub stats {
    my $self = shift;
    $self->drawings(
        ["status", thestatus()]
    );
}
sub thestatus { "There are ".scalar(@main::links)." links" }

sub boxen {
    my $self = shift;
    $self->drawings(
        ["clear"],
        ["status", thestatus()],
        @boxen,
    );
}

sub object {
    my $self = shift;
    my $id = $self->param('id');
    my @timings;
    push @timings, "start: ".show_delta();
    my $object = get_linked_object_by_memory_address($id);
    unless ($object) {
        return $self->sttus("$id no longer exists!");
    }

    if ($viewed && $viewed->first."" eq $object) {
        return $self->sttus("same diff");
    }
    my (@drawings, @animations, @removals);

    my $subset = new Graph;
    my $trav = Travel->new(ignore =>
        ["->{no_of_links}", "->{iggy}"]);

    $trav->travel($object, sub {
        my ($G, $ex) = @_;
        if ($ex->{previous}) {
            my $found = $subset
                ->find($ex->{previous});
            $found
                ->spawn($G, $ex->{via_link});
        }
        else {
            $subset->spawn($G);
        }
    });

    my $first_node = $subset->first;
    $trav->travel($first_node,
        all_links => sub {
            $_[0]->spawn({no_of_links => scalar @{$_[2]}})
        },
    );

    my $new_svg = $subset->spawn({iggy => "..."});

    my $nameidcolor = sub {
        my $summarised = shift;
        if ($summarised =~
            m{^(?:Node )?\s*([\w -]+)=.+\((0x...(...).)\)}) {
            my ($name, $id, $color) = ($1, $2, $3);
            $name = "$name $id";
            return ($name, $id, $color);
        }
        else {
            $DB::single = 1;
        }
    };


    my ($x, $y) = (20, 40);
    my $ids = {};
    $trav->travel($first_node, sub {
        my ($G, $ex) = @_;
        my $x = $x + $ex->{depth} * 18;
        $y += 18;
        my $stuff = summarise($G);
        my ($linknode) = grep { $_->thing->{no_of_links} } $G->linked;
        my $no_of_links = $linknode->thing->{no_of_links}
            if $linknode;

        $DB::single = 1;
        my ($name, $id, $color) = $nameidcolor->($stuff);
        my $oxble_uniq = uniquify_id($ids, "${id}oxble");
        $ids->{$oxble_uniq} = undef;
        my $settings = sub {
            my $kind = shift;
            my $settings = { fill => $color, id => $id,
                class => "$oxble_uniq, $color, $id", name => $name };
            return $settings;
        };

        my $box_set = $settings->("boxen");
        $new_svg->link($G,
            [ "boxen", $x-20, $y-2, 18, 18, $box_set ]
        );

        my $lab_set = $settings->("label");
        delete $lab_set->{fill};
        if ($no_of_links > 1) {
            $lab_set->{'font-weight'} = "bold";
        }
        $new_svg->link($G,
            [ "label", $x, $y, $stuff, $lab_set]
        );
    });

    my $preserve = $subset->spawn({});
    $trav->travel($first_node, sub {
        my ($new, $ex) = @_;
        my $old = $viewed && $viewed->find($new->thing);
        if ($old) {
            $preserve->link($old);

            my $bitsof = sub {
                my ($from, $what) = @_;
                my $bits = {};
                for my $b (map { $_->{val}->[0] } $from->links($what)) {
                    $bits->{$b->[0]} = $b;
                }
                return $bits;
            };

            my $bits = {
                old => $bitsof->($old, $old_svg),
                new => $bitsof->($new, $new_svg),
            };

            my ($oxble_uniq) = $bits->{new}->{boxen}->[-1]->{class}
                =~ /^(\S+),/;

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
            push @animations, ["animate", $oxble_uniq,
                {svgTransform => "translate($trans)"},
                300];
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
            $DB::single = 1;
            unless ($preserve->links($subset->find($G))) {
                my $sum = summarise($G);
                my @tup = $nameidcolor->($sum);
                my $id = $tup[1];
                push @removals, ["remove", $id ];
            }
        });
    }

    $viewed = $subset;
    $old_svg = $new_svg;

    @drawings = (@removals, @animations, @drawings);

    push @timings, "enzot: ".show_delta();
    unshift @drawings, 
        ["status", "For ". Dump($object)];
    push @drawings,
        [label => 10, 20 => join(" ... ", @timings)];
    $self->drawings(@drawings);
}

sub object_info {
    my $self = shift;
    $self->render("404");
}

use Mojolicious::Lite;
get '/' => 'index';
get '/stats' => \&stats;
get '/boxen' => \&boxen;
get '/object' => \&object;
get '/hello' => \&hello;
get '/object_info' => \&object_info;
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

