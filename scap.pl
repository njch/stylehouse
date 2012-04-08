#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

my $junk = new Stuff("Junk");
my ($one, @etc) = map { $_->link($junk); $_ }
    map { new Text($_) }
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Meal.flac",
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac",
    "/home/steve/Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac";

my $wants = new Stuff("Wants");
my $code = new Stuff("Code");
our @links;
our $G = new Stuff("Nothing");
our $root = $G;
our @entropy_fields;
sub entropy_increases {
    $_->{at_maximum_entropy} = 0 for @entropy_fields;
}

=pod
so from everywhere we can see $G, which is the current point on the graph
$G->spawn(...) to add a branch
then something maxes entropy on that little island of logic
  like a lexical scope, being coded together out of known intellect
then things are executed
so you see the division between code and data is blurred into a graph
we shall call the maxing of entropy evaportation
the evaportation may build more graph, which is solved first

so given a datastructure, we spawn code objects
everything sorts itself out until it's done
then executables are run
=cut

sub do_stuff {

    start_timer();
    my $clicks = 0;
    until ($root->{at_maximum_entropy} || $clicks++ > 21) {
        $root->{at_maximum_entropy} = 1;
        my $click = $root->spawn("Click");
        say "\nclick!\n";
        process("Click");
        say Dump($G);
        exit;
    }
    say "$clicks clicks in ". show_delta();
}

$code->spawn(
[ "Click", be => sub { process({Linked => $wants}) } ],
[ "Linked", be => sub { shift->linked } ],
);

sub process {
    my $d = shift;
    my $dir = $G;
    local @entropy_fields = (@entropy_fields, $dir);
    # run ready, which does patterny preparations without executing anything
    until ($dir->{at_maximum_entropy}) {
        $dir->{at_maximum_entropy} = 1;
        # TODO apply pattern matches, somehow with a clue that $d has't been processed
        ready($d);
        # TODO apply pattern matches
    }
    # TODO execute

sub ready {
    my $d = shift; # the nugget
    # $G is god now!
    # be sure that $G at_maximum_entropy gets set appropriately
    if (ref $d eq "ARRAY") {
        $G->spawn("Sequence", @$d);
        say "Jhurtiiz: ".Dump($g);
        die;
    }
    elsif (ref $d eq "HASH") {
        my (%di, %db);
        while (my ($d, $i) = each %$d) {
            $di{$d} = new Stuff("In", it => $i); # instruction, given to
            $db{$d} = [ $code->linked($k) ];     # behaviour
        }
        # this is like a lexical scope, involving possibly many
        # algorithms intertwining dependence/other forces on each other.
        # finding the codes is more special than just search I think...
        # we might want to define (A and B) as well as individually
        # TODO crunch()
        # compose order... fire them just so
        # composed from known algorithm territory, chunks of intellect...
        # get things to apply themselves to $G:
        my $new_cleverness = crunch(\%di, \%db);
        $G->spawn($new_cleverness);
        return
    }
    elsif (ref $d eq "CODE") {
        $g->spawn("Code", it => $d);
    }
    else {
        $g->spawn("Data", it => $d);
    }
}

        

sub search { # {{{
    my %more;
    if (@_ % 2) {
        $more{spec} = shift;
        $more{want} = "linked";
    }
    else {
        %more = @_;
    }
    
    my $want = $more{want}; # links/linked
    my $spec = $more{spec};
    my @spec;
    if (ref $spec) {
        @spec = $spec;
    }
    elsif ($spec) {
        @spec = split "->", $spec;
    }
    my $start_from = $more{start_from};
    $start_from ||= shift @spec;
    my $findlinks = sub {
        my ($from, $to) = @_;
        return grep {
            main::spec_comp($to, $_->{1})
        } map {
            main::order_link($from, $_);
        } @links
    };
    my $dospec;
    my $rtree = {};
    my $take_results = sub {
        my ($from, $rs) = @_;
    };
    $dospec = sub {
        my ($rs, @spec) = @_;
        my @flin;
        my $to = shift @spec;
        for my $from (@$rs) {
            my @ls = $findlinks->($from, $to);
            my @res = map { $_->{1} } @ls;
            $take_results->(
                !@ls ? "404 ($from)" : "$ls[0]->{0}",
                \@ls
            );
            if (@spec) {
                @ls = $dospec->(\@res, @spec);
            }
            push @flin, @ls;
        }
        return uniq @flin;
    };
    
    if (!$spec) {
        return $findlinks->($start_from, "*");
    }
    my @ar = $dospec->([$start_from], @spec);
    say sum($start_from)." $more{spec} ". scalar @ar;

    $DB::single = 1;
    my $callers = sub { [reverse((caller(shift || 1))[0..3])] };
    my @ca = ($callers->(), $callers->(2), $callers->(3));
    say "  : ". join "   ", map { join("/", @$_) } @ca;
    
    return @ar; 
}

sub spec_comp {
    my $spec = shift;
    my $thing = shift;
    
    return 1 if $spec && $spec eq "*";
    ref $spec   ? $thing eq $spec      # an object
    : $spec     ? ref $thing eq $spec  # package name
    : 1
}

sub order_link { # also greps for the spec $us
    my ($us, $l) = @_;
    if (spec_comp($us, $l->{0})) {
        return $l
    }
    elsif (spec_comp($us, $l->{1})) {
        return {
            1 => $_->{0}, 0 => $_->{1},
            val => $_->{val}, id => $_->{id}
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
    bless {@_}, $package;
}
sub spawn {
    my $self = shift;
    if (ref $_[0] eq "ARRAY") {
        $self->spawn(@$_) for @_;
    }
    else {
        my $new = new Stuff(@_);
        $self->link($new);
        if ($self eq $G) {
            $G = $new
        }
        return $new
    }
}
sub link {
    entropy_increases();
    $_[0] && $_[1] && $_[0] ne $_[1] || die "linkybusiness";
    push @links, {0=>shift, 1=>shift,
                val=>\@_, id=>scalar(@links)}; # self, other, ...
    return $_[0]
}
sub unlink {
    entropy_increases();
    my $self = shift;
    my $other = shift;
    my @ls = $self->links($other);
    for my $l (@ls) {
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
    
    return main::search(
        start_from => $self,
        spec => $spec,
    );
}
} {
package Transducer;
use base 'Stuff';
sub new {
    shift; # Transducer
    my $self = Stuff::new(shift, {base=>"Transducer"}, @_);
    $self->{name} ||= ref $self;
    $self
}
sub do {
    my $self = shift;
    # make @_ findable and then be

}
sub find_the {
    my $self = shift;
    my $what = shift;
    my $pyramid_scheme = \@main::pyramid_scheme;
    # TODO this is a kind of search.
    # search should be all about traversal and such
    # surrounding functions apply aggregation and whatever
    # and what graph arches to look along, here we want state first
    $self->{$what} || do {
        my ($ok) = map { $_->{$what} } grep { $_->{$what} } map { @$_ } reverse @$pyramid_scheme;
        $ok
    }
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
    } else { die }
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

require 'Intuitor.pl';
#require 'Scap2Blog.pl';

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
    my $text = "$thing";
    my ($id) = $thing =~ /\((.+)\)/ or moan "summarise not a ref!?";
    my ($color) = $id =~ /(...)$/;
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
    }
    return $text;
    return sprintf '<li id="%s" style="background-color: #%s">%s</li>', $id, $color, $text, $id;
}

sub link2text {
    my $l = shift;
    "$l->{1}" =~ /^(\w+)/;
    my $name = $1;
    $name = summarise($l->{1});
    my $val = join " ", "_", tup($l->{val}), $name;
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

        if (!defined $l->{1}) {
            warn "undef link: $l->{id}";
            return "UNDEFINED!"
        }
        if ($n++ > 100) {
            return "DEEP RECURSION!"
        }

        my $o = $l->{1};
        my $oid = "$o";

        my $prev = exists $seen_oids{$oid};
        my $ob = $seen_oids{$oid} ||= { summarise($o) => [] };
        my ($linkstash) = values %$ob;

        unless ($prev) { # || $o =~ /Intuition/) {
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
            push @$tree, { $l->{text}, $figure_link->($l) };
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
