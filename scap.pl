#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

my $junk = new Stuff("Junk"); #{{{
my ($one, @etc) = map { $junk->link($_); $_ }
    map { new Text($_) }
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Meal.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac",
    "/home/steve/Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac";

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

my $test = 0;
my @modules = (
"Intuitor",
#"Scap2Blog",
);
sub do_stuff {
    start_timer();
    if ($test == 1) {
    my $td = LoadFile('search_testdata.yml');
    #use Test::More 'no_plan';
    my $round = 1;
    for my $t (@$td) {
        my ($args, $ret, $links) = @{ Load($t) };
        @links = @$links;
        $DB::single = $round++ == 54;
        my $aret = [ search(@$args) ];
        my @args = map { !defined $_ ? "undef" : $_ } @$args;
        is_deeply($aret, $ret, "@args correct!")
            || do {
                $DB::single = 1;
                say Dump([$aret, $ret])
            };
    }
    say " okay:". show_delta();
    return;
    }
    else {
    my $clicks = 0;
    until ($root->{at_maximum_entropy} || $clicks++ > 21) {
        $root->{at_maximum_entropy} = 1;
        $clicks++ && say "\nclick!\n";
        process({Linked => $wants});
        last
    }
    say "$clicks clicks in ". show_delta();
    }
}

my $dumpstruction = new Stuff("DS"); #{{{
use JSON::XS;
$dumpstruction->spawn(
[ "If", be => sub { "If expr=".($_[0]->{EXPR}||"") } ],
[ "In", be => sub { "In ".join" ",tup($_[0]->{it}) } ],
);
$code->spawn(
[ "Click", be => sub { process({Linked => $wants}) } ],
[ "Linked", be => sub { 
    transmog($G => $G->In->{it}->[0]->linked) } ],
[ "Flow", be => sub { $G->{be}->($G) } ],
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
            say "Pattern linked as @objects";
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
sub travel {
    $G = shift || $G;
    my $ex = shift if ref $_[0] eq "HASH";
    $ex ||= {};
    unless ($ex->{seen_oids}) {
        $ex->{depth} = 0;
        $ex->{seen_oids} = {};
        $ex->{via_link} = -1;
    }

    if ($ex->{depth}++ > 50) {
        warn "DEEP RECURSION!";
        return "DEEP RECURSION!"
    }

    if ($ex->{everywhere}) {
        $ex->{everywhere}->($G, $ex)
    }

    my @links = getlinks(from => $G);
    @links = grep { 
        ! ($_[0] eq $ex->{via_link}
           || exists $ex->{seen_oids}->{"$_[0]->{1}"})
        } @links;

    if ($ex->{greplink}) {
        @links = grep { $ex->{greplink}->($_) } @links
    }

    $ex->{seen_oids}->{"$G"} ||= { summarise($G) => \@links };

    for my $l (@links) {
        $ex->{via_link} = $l;
        
        say "TRAVELOONG $l->{0} -> $l->{1}";
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
    say "linking @_";
    my ($I, $II, @val) = @_;
    $I && $II && $I ne $II || die "linkybusiness";
    my $l = {
        0 => $I, 1 => $II,
        val => \@val, id => $main::ln++,
    };

    # TODO field attachment

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
} # }}}
{ package Text;
# uhm...
use base 'Stuff';
sub new { shift; bless { text => shift }, __PACKAGE__; }
sub text {
    shift->{text}
}
}
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

for (@modules) {
    say "loading $_...";
    require "$_.pl";
}

do_stuff();

# DISPLAY
exit;
displo($wants);
exit;


exit;

sub sum {
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
};

my %seen_oids;
my $n= 0;
sub assplain {
    my ($thing, $previous_lid) = @_;
    my %links = links_by_id($thing->links);
    my %by_other = links_by_other_type(%links);

    my $figure_link = sub {
        my $l = shift;

        if ($l->{id} eq $previous_lid) {
            return 
        }
        if (!defined $l->{1}) {
            warn "undef link: $l->{id}";
            return "UNDEFINED!"
        }
        if ($n++ > 50) {
            return "DEEP RECURSION!"
        }

        my $o = $l->{1};
        my $oid = "$o";

        my $prev = exists $seen_oids{$oid};
        my $ob = $seen_oids{$oid} ||= { summarise($o) => [] };
        my ($linkstash) = values %$ob;

        if ($o eq $code) {
            @$linkstash = ("...");
        }
        elsif (!$prev) {
            my $connective = assplain($l->{1}, $l->{id});
            push @$linkstash, @$connective;
        }

        return $ob;
    };

    my $tree = [];
    unless ($previous_lid) {
        $previous_lid = -1;
        push @$tree, summarise($thing);
    }
    for my $k (sort keys %by_other) {
        for my $l (@{$by_other{$k}}) {
            my $fig = $figure_link->($l);
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
}


sub treez {
    my $self = shift;
    my $text = "";
    $self->render(text => $text);
}
exit;

use Mojolicious::Lite;
use JSON::XS;
get '/' => 'index';
get '/ajax' => \&treez;
use Mojo::Server::Daemon;

my $daemon = Mojo::Server::Daemon->new;
$daemon->listen(['http://*:3000']);
$daemon->run;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>scap!</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <script type="text/javascript" src="scope.js"></script></head>
    <body style="background: black"><ul></ul></body>
</html>
