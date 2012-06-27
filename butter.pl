#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

our $json = JSON::XS->new()->convert_blessed(1);

=pod NEW FILE!

needing to move the architecture forward without the clunkiness and the many
hundred estranged lines of code

in this file:
focus on being able to play with the scope
make some algorithms to play with there
composable stuff (algorithms)
finally an answer to what is a field and how it works

and DONT FORGET TO TAKE GUITAR BREAKS


etc



so eventually the Graph/Node infrastructure code will be represented on itself
so hacks can be loaded in without impurifying the basic apparition of IT.
those hacks, being datastructure concerns, should be compiled back into CODEs
the system tests the new tech then just changes some links to hop over to it

I suppose this means sucking in the Graph/Node code and making it an algorithm
graph, dumping it back into code with adjustments...


So there's usually just one graph per App
App would branch away its various data but it's one bunch of links
a perl program in this new world would be more like a daemon serving
the illusion of several Apps and whatever they need, down to the existing tech

linking more in a graph means node linkage
linking an alien object means it is put in a node and the node is linked in
the node is appropriately transparent:
    ->links() for eg is a node method, non-node method calls are passed
    through the node so $G is set up for any graphy business the object wants

we also want to create graphs that are subsets of larger graphs
each node in the subset could be linked to the original in secret way
(if a query asked it could traverse back into the original graph)
once we have subsets carved out we can run them into algorithms easier

there's kind of a turf concept going on... various customs for travellers...

case study of different graphs, as a flow diagram:
    run a graph query
    figure out how to SVG the results
      - sorting branches
      - spacing things out...
    diff that SVG <-> user's SVG
    drawing instructions for the user's SVG canvas

we're almost up to here... not spacing things out though

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

# TODO
sub search {
    my %p = @_;
    return getlinks(from => $p{start_from}, spec => $p{spec});
}
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
}


sub tup {
    my $tuple = shift;
    ref $tuple eq "ARRAY" ? @$tuple : $tuple;
}


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

