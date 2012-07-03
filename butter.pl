#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use JSON::XS;
use List::MoreUtils qw"uniq";
use File::Slurp;
use Scriptalicious;
use Carp 'confess';
use v5.10;

our $json = JSON::XS->new()->convert_blessed(1);
our $webbery = new Graph('webbery');
our $G;

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

perhaps this can be thought of as an experiment to determine the nature of field
a field is the scope of determinism in existence

anyway data flows through algorithms, each datum shouldn't invoke the whole
shebang once for itself, resources should be bundled together where possible
for instance finding files as we are and linking them to their directory,
could be done with a hash much faster than using find() for what it really means
so it seems the basic Graph/Node/Traveller stuff is supplanted, nay, hot-hacked
into line with new graphy rules. graph system holds graph, creates another
graph system, etc. great. so it needs to hack up perl code pretty much first...
but it's all so well layed out it can't be too much trouble. exciting stuff to
get on with.
but yeah, streaming algorithms that can make shortcuts for big datasets.
the question is how to express this in graph so it scales...
also start using the server for this bullox.
nodes could store links on themselves if it made sense...
all these slight tweaks in nature "if it makes sense" are obviously coming from
the world of graph self-analysis and optimisation...
firstly we should break the /object code into functions which feed each other..
or the getlinks() code, why not...
the variables' light cone allows the shape of the algorithm around it to change.
inputs and outputs, chains of them

=cut


our %graphs; # {{{
package Graph;
use YAML::Syck;
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
    main::moan "diff graphs: ".$I->graph->{name}." vs ".$II->graph->{name}.":  ". main::summarise($I) . "\t\t" . main::summarise($II)
        if $I->graph ne $II->graph;
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
    for (@to_unlink) {
        die "different graphs..".Dump($_)
            if $_->{1}->{graph} ne $_->{0}->{graph}
                || $_->{1}->{graph} ne $self->{name}
    }
    $to_unlink{$_->{_id} || "$_"} = undef for @to_unlink;
    my $links = $self->{links};
    for my $i (reverse 0..@$links-1) {
        if (exists $to_unlink{$links->[$i]}) {
            my $name = $links->[$i];
            splice @$links, $i, 1;
            delete $to_unlink{$name};
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
sub find_id {
    my ($self, $id) = @_;
    my $node;
    eval { $self->map_nodes(sub { "$_[0]" =~ $id && do { $node = $_[0]; } }) };
    $@ = "" if $node;
    die $@ if $@;
    return $node;
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
    say "DESTROY ".main::summarise($self);
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
    $self->{fields} = \@fields if @fields;
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
    $spawn->{fields} = [ @{ $self->{fields} } ] if $self->{fields};
    return $spawn;
}
sub field {
    my $self = shift;
    $self->{fields} = shift if $_[0];
    $self->{fields};
}
sub id {
    my $self = shift;
    my $id = shift;
    $id =~ s/^#//;
    $self->{id} = $id;
}
sub trash {
    my $self = shift;
    my $field = shift;
    # TODO travel to the extremities of $field deleting everything...
    for my $n ($self->linked) {
        if ($field && $field ne $n->{field}) {
            say "$n not in $field";
            next;
        }
        $self->unlink($n);
        $n->{thing}->DESTROY if ref $n->{thing} eq "Graph";
    }
}
sub graph {
    $main::graphs{$_[0]->{graph}} || die "no graph $_[0]->{graph}";
}
sub link {
    $_[0]->graph->link(@_)
}
sub unlink {
    my ($self, @others) = @_;
    my @links;
    for my $o (@others) {
        for my $l ($self->links($o)) {
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
              : /^(\w+)$/ ? do {
                my $w = $1;
                sub {
                    $_[0]->{1}->thing eq $w
                }
            } :
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
package main;
#}}}

use File::Find;
start_timer();
my $fs = new Graph ("filesystem"); #{{{
my $fs_head = $fs->spawn("/home/steve/Music/The Human Instinct");
find(sub {
    return if $_ eq "." || $_ =~ /\/\.rockbox/;
    say $File::Find::name;
    my $dir = $fs->find($File::Find::dir);
    $dir || die "no dir... $File::Find::dir";
    $dir->spawn($File::Find::name);
}, $fs_head->thing);
say "AG'd: ". show_delta();
#DumpFile("ag_fs.yml", $fs); # }}}

my $findable = $webbery->spawn("findable_objects");
$findable->link($fs);
$findable->link($fs_head);
$findable->link($webbery);

my $codes = new Graph("codes");#{{{

my $get_object = graph_code($codes, "sub get_object");

$findable->link($codes);
$findable->link($get_object);

sub graph_code { 
    my ($codes, $section) = @_;
    my @code = read_file('butter.pl');
    $codes = $codes->spawn($section);
    while ($_ = shift @code) {
        next until /^\Q$section\E/;
        my $chunk;
        $_ = " ";
        until (/^\S/) {
            $chunk .= $_ = shift @code;
            if (/^\s*$/sm && $chunk =~ /\S/) {
                $codes->spawn({ code => $chunk });
                $chunk = "";
                shift @code until $code[0] =~ /\S/;
            }
        }
        if ($chunk =~ /\S/) {
            $chunk =~ s/\};?\s*\Z//xsm;
            $codes->spawn({ code => $chunk });
        }
    }
    my $chunk_i = 0;
    travel($codes, sub {
        my ($chunk) = @_;
        $chunk->thing->{i} = $chunk_i++;
    });
    return $codes;
} # }}}


# {{{

sub get_linked_object_by_memory_address {
    my $id = shift;
    for my $o ($findable->linked) {
        return $o if "$o" =~ /\Q$id\E/;
        return $o if ref $o eq "Node" && "$o->{thing}" =~ /\Q$id\E/;
        if (ref $o->{thing} eq "Graph") {

            return $o->{thing}->find_id($id) || next
        }
    }
}
=pod ENTROPY FIELD
some crazy shit. for post-X.

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
=cut 

# TODO
sub search {
    my %p = @_;
    return getlinks(from => $p{start_from}, to => $p{spec});
}
sub getlinks {
    my %p = @_;

    my @links;
    @links = @{$p{to}->graph->{links}}
        if $p{to} && ref $p{to} eq "Node";
    if ($p{from} && ref $p{from} eq "Node") {
        @links = @{$p{from}->graph->{links}}
    }

    @links = map { main::order_link($p{from}, $_) } @links if $p{from};
    @links = grep { main::spec_comp($p{to}, $_) } @links if $p{to};

    return @links;
}

sub goof {
    my ($start, $etc) = @_;
    if ($etc =~ /^\+ (#\w+) (\{\})$/) { # + means autovivify
        my ($spec, $default) = ($1, $2);
        my @ed = $start->linked($spec);
        confess "heaps of $spec from $start: ".Dump[@ed] if @ed > 1;
        my $ed = shift @ed;
        unless ($ed) {
            eval '$default = '.$default.';';
            confess "interpolating $default: $@" if $@;
            $ed = $start->spawn($default);
            $ed->id($spec);
        }
        return $ed;
    }
    else {
        confess "goof $start: $etc is crazy";
    }
}

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
    my $node = shift;
    my $l;
    if (ref $node eq "HASH") {
        $l = $node;
        $node = $l->{1};
    }
    my $thing = $node->{thing};

    if ($spec =~ /^#(\w+)/) {
        my $id = $1;
        return $node->{id} && $node->{id} eq $id;
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

sub summarise { # SUM
    my $thing = shift;
    my $text;
    given (ref $thing) {
        when ("Graph") {
            $text = "Graph $thing->{name}"
        }
        when ("Node") {
            my $inner = $thing->thing;
            $text = "N($thing->{graph}) ".summarise($inner);
            unless (ref $inner eq "Node") {
                my ($addy) = $thing =~ /(\(0x.{7}\))/;
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
            }
        }
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



our $whereto = ["boxen", {}];
$whereto = [object => { id => "". $get_object }];

$findable->link($webbery->spawn("clients"));
our $us; # client - low priority: sessions

use Mojolicious::Lite;
get '/hello' => \&hello;
sub hello {
    my $self = shift;

    my $client_id = "the";

    # trash the old state
    for my $client ($webbery->find("clients")->linked()) {
        if ($client->{thing} eq $client_id) {
            $client->trash()
        }
    }

    $us = $webbery->find("clients")->spawn("the");

    $self->render(json => $whereto);
};
get '/stats' => sub {
    $_[0]->drawings(["status", "hi"]);
};
my $findable_y = 20;
get '/boxen' => sub {
    my $self = shift;
    $self->drawings(
        ["clear"],
        draw_findable(),
    );
};

get '/width' => sub {
    my $self = shift;
    my $width = $self->param('width');
    $us->spawn({width => $width});
    $self->render(json => "Q");
};

sub draw_findable {
    my $self = shift;
    my $findable_y = $findable_y;
    my ($width) = map { $_->{thing}->{width} }
        grep { ref $_->{thing} eq "HASH" && $_->{thing}->{width} }
        $us->linked();
    my $x = $width - 35;

    my $svg = $self->svg();
    my @new;
    for my $ble ($webbery->find("findable_objects")->linked()) {
        if ($ble->links($svg) == 2) {
            say "$ble->{thing} already on screen";
            next;
        }

        say "making $ble->{thing} findable..";
        my ($name, $id, $color) = "$ble" =~ m{^(\w+)=.+\((0x...(...).)\)$};
        $name = "$name $id";
        my $sum = summarise($ble);
        push @new, grep { $svg->link($ble, $_); 1 }
            ["boxen", $x, do { $findable_y += 40 }, 30, 30,
                { fill => $color, name => $name, id => $id, } ],
            ["label", $x - length($sum)*8.5, $findable_y, $sum,
                { id => $id } ]
    }
    return @new;
}
=pod
/object means examination gets new id;
that creates a new limb, to create graph and svg stuff
then at the end the New SVG Stuff as determined purely by linkage to us->svg
=cut

sub happs {
    my ($web, $act) = @_;


}


get '/object' => \&get_object;
sub get_object { # OBJ
    my $self = shift;
    my $id = $self->param('id')
        || die "no id";
    my $object = get_linked_object_by_memory_address($id)
        || return $self->sttus("$id no longer exists!");
    unless (ref $object eq "Node") {
        return $self->sttus("don't like to objectify ".ref $object);
    }

    # find the VIEWED graph: existing subset and svg info
    my @viewed = grep { ref $_->{thing} eq "Graph"
                        && $_->{thing}->{name} =~ "^object-examination" } $us->linked();
    my (@etc, $viewed) = @viewed;
    if (@etc) {
        moan "Viewedes";
        $us->unlink($_) for @etc;
    }
    ($viewed, my $viewed_node) = ($viewed->thing, $viewed) if $viewed;

    if ($viewed && $viewed->first && $viewed->first->thing."" eq $object) {
        return $self->sttus("same diff");
    }


    my (@drawings, @animations, @removals);


    # TODO this is a travel()/search() result-as-graph idea
    my $exam = $us->spawn(Graph->new('object-examination'));
    $exam = $exam->{thing};

    my $trav = Travel->new(ignore =>
        ["->{no_of_links}", "->{iggy}", "findable_objects"]);

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
            $_[0]->spawn({iggy => 1, no_of_links => scalar @{$_[2]}})
        },
    );

    my $svg = $self->svg;

    my $nameidcolor = sub {
        my $summarised = shift;
        if ($summarised =~
            m{^(?:N\(.+?\) )*(.+) \((0x...(...).)\)$}) {
            my ($name, $id, $color) = ($1, $2, $3);
            $name = "$name $id";
            return ($name, $id, $color);
        }
        else {
            return ("$summarised", "???", "000");
        }
    };


    my ($ids) = grep { ref $_->{thing} eq "HASH"
        && $_->{thing}->{ids} } $us->linked;
    $ids ||= do { $us->spawn({ids => {}})->{ids} };

    $DB::single = 1;
    my ($x, $y) = (30, 40);


    $trav->travel($head, sub {
        my ($G, $ex) = @_;
        my $thing = $G->{thing};
        return if $thing eq "svg";
        return if $thing->{iggy};
        die "urm ".Dump($thing) unless ref $thing eq "Node";
        $thing = $thing->{thing};

        my $x = $x + $ex->{depth} * 20;
        $y += 20;
        my $stuff = summarise($G);
        $stuff =~ s/^N\($exam->{name}\) //;

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
                class => [$oxble_uniq, $color, $id], name => $name };
            return $settings;
        };

        my $box_set = $settings->("boxen");
        $svg->link($G,
            [ "boxen", $x-20, $y-2, 18, 18, $box_set ]
        );

        my $lab_set = $settings->("label");
        delete $lab_set->{fill};
        if ($no_of_links && $no_of_links > 1) {
            $lab_set->{'font-weight'} = "bold";
        }
        if (ref $thing eq "HASH" && $thing->{code}) {
            my $li = 1;
            for my $line (split /\n/, $thing->{code} ) {
                my ($ind) = $line =~ /^( +)/;
                my $x = $x + (length($ind)-4) * 10;
                my $lab_set = { %$lab_set };
                $lab_set->{class} = [ @{$lab_set->{class}} ];
                $lab_set->{class}->[0] .= "-$li";
                $lab_set->{id} .= "-$li";
                $svg->link($G,
                    [ "label", $x, $y, $line, $lab_set]
                );
                $li++;
                $y += 14;
            }
        }
        else {
            $svg->link($G,
                [ "label", $x, $y, $stuff, $lab_set]
            );
        }
    });
    
    my $preserve = $exam->spawn("preserve");
    $trav->travel($head, sub {
        my ($new, $ex) = @_;
        my @old = $viewed->find($new->thing) if $viewed;
        my ($old) = grep { !$_->linked($preserve) } @old;
        if ($old) {
            $preserve->link($old);
     
            my @olds = map { $_->{val}->[0] } $old->links($svg);
            die "hmm" if @olds != 2;
            my @news = map { $_->{val}->[0] } $new->links($svg);
            die "har" if @news != 2;

            my ($oxble_uniq) = split /\s/, $olds[0]->[-1]->{class};

            my $bits;
            for ([old => @olds], [new => @news]) {
                my ($e, @d) = @$_;
                for my $ds (@d) {
                    $bits->{$e}->{$ds->[0]} = $ds;
                }
            }

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
            my @whats = $svg->links($new);
            @whats = map { $_->{val}->[0] } @whats; # new: label, boxen
            push @drawings, @whats;
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
            $G->unlink($svg);
        });
    }
    
    
    my $clear;
    unless ($viewed) {
        $clear = 1;
    }
    else {
        $viewed->DESTROY(); # can't translate() twice so trash it
        $viewed_node->unlink($us);
    }

    @drawings = (@removals, @animations, @drawings, draw_findable($self));

    # join together the class="etc etc etc" setting
    map { ref $_->[-1] eq "HASH" && ref $_->[-1]->{class} eq "ARRAY" && do {
        $_->[-1]->{class} = join " ", @{ delete $_->[-1]->{class} }
    } } @drawings;

    my $status = "For ". summarise($object);
    unshift @drawings, 
        ["status", $status];
    unshift @drawings, ["clear"] if $clear;
    $self->drawings(@drawings);
};

get '/object_info' => sub {
    my $self = shift;
    $self->render("404");
};

get '/' => 'index';

*Mojolicious::Controller::svg = \&procure_svg;
sub procure_svg {
    $main::us || confess "Argsh";
    my ($svg) = grep { $_->{thing} eq 'svg' } $main::us->linked;
    $svg ||= $main::us->spawn('svg');
};
*Mojolicious::Controller::drawings = sub {
    my $self = shift;
    say scalar(@_)." drawings";
    use Storable 'dclone';
    DumpFile("drawings.yml", dclone([@_]));
#    my $a = LoadFile ( 'srawnbjgs');
    my $a = [@_];
    $self->render(json => $a);
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
    <style type="text/css">
    @import "jquery.svg.css";
    </style>
    <script type="text/javascript" src="jquery.svg.js"></script>
    <script type="text/javascript" src="jquery.svganim.js"></script>
    <script type="text/javascript" src="scope.js"></script></head>
    <body style="background: #897; font-family: monospace">
    <div id="view" style="background: #239"></div>
    </body>
</html>

