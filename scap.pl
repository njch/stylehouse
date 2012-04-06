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
our $at_maximum_entropy = 0;
our @links;
our @pyramid_scheme;

sub be {
    my $it = shift;
    push @pyramid_scheme, [$it, @_];
    $it->{be}->($it, @_);
    pop @pyramid_scheme;
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
sub link {
    $at_maximum_entropy = 0;
    $_[0] && $_[1] && $_[0] ne $_[1] || die "linkybusiness";
    push @links, {0=>shift, 1=>shift,
                val=>\@_, id=>scalar(@links)}; # self, other, ...
    return $_[0]
}
sub unlink {
    $at_maximum_entropy = 0;
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

new Flow(
name => "Intuitor", # {{{
#want => new Pattern(object => "Text"),
be => sub {
    my $self = shift;
    my $it = shift;

    unless ($self->linked("Intuition")) {
# here we generate some intuitions and their matches 
# {{{
my @giv = split "\n", <<"";
string:
    /\// maybe filename
filename:
    /^\\.\\.//  probly relative
    /^(?!/)/ maybe relative
    /^//    probly absolute
    { -e shift } is reachable
relative or absolute
reachable filename:
    { -f shift } is file
    { -d shift } is dir
file or dir
file:
    { -r shift } is readable
    { (stat(shift))[7] } is size

sub shift_until { # TODO util functions
    my ($shift, $until) = @_;
    my @ret;
    until (!@$shift || $until->()) {
        push @ret, shift @$shift;
    }
    return @ret;
}

while (defined($_ = shift @giv)) {
    if (/^([\w ]+):/) {

        my $in_match = $1 eq "string" ?
            new Pattern(
                object => "Text"
            ) :
            new Pattern(
                object => "Intuition",
                names => [split /\s+/, $1]
            );

        my @ints = shift_until(\@giv, sub { $giv[0] =~ /^\S/ });

        for (@ints) {
            s/^\s+//;
            my $cog =
                s/^\/(.+)\/ // ? qr"$1" :
                s/^\{(.+)\} // ? eval "sub { $1 }" :
                die $_;
            my ($cer, $to) = /^\s*(\w+)\s+(\w+)$/;
            $cer && $to || die;
            my $int = new Stuff("Intuition",
#   name => "word", the word describing a positive intuition
#   cer => is|probly|maybe|slight, security of knowledge
#           greater arrangements made out of uncertainties should be upgraded
#   cog => regex or code->($_) to test
                name => $to,
                cer => $cer,
                cog => $cog,
            );
            $int->link($in_match);
            $int->link($self);
        }

    }
    elsif (/^([\w ]+)$/) {
        my @mutex = split / or / || die;
        # things that cannot be all true
        # should work like Intuitions except it projects LIES unto the
        # stuff that's wrong
    }
    else { die $_ }
}
# }}}
    }
    else {
        my @patterns = $self->linked("Intuition->Pattern");
        my @matching = grep { $_->match($it) } @patterns;
        my @ints = map { $_->linked("Intuition") } @matching;

        for my $int (@ints) {
            next if $int->links($it); # already

            # say " looking: $self->{cer} $self->{name}...";
            my $cog = $int->{cog};
            my $t = $it->text;
            my @val = 
                ref $cog eq "Regexp" ? $t =~ $cog :
                ref $cog eq "CODE" ? $cog->($t) :
                die;
            # say @val ? "   @val" : "NOPE";
            @val = [@val] if @val > 1;
            @val = (1) if @val == 0 && ref $cog ne "Regexp";

            # say "intuited $self->{name}";
            $int->link($it, @val);
        }
    }
},
); # }}}

new Flow(
name => "scap2blog",
want => "satisfaction",
filename => do { use FindBin '$Script'; $Script },
be => sub {
    my $self = shift;
    my $tl = text_liner();
    # TODO see overload the Transducer, so:
    # my $sel = $tl->select(...)->trim_white;
    # pass $sel to blog stash...
    be($tl, {select => q[after 'use v5.10' and before 'my $junk =']});
    be($tl, {unselect => qr/^\s+$/});
    say Dump([
        map { $_->{1}->{text} } search("LineSelection->Text")
    ]);
    exit;
},
);

sub text_liner {
    my $tl =
new Transducer("TextLinerFile",
    be => sub {
        my $self = shift;
        unless ($self->linked("Text")) {
            use File::Slurp;
            my @lines = read_file($self->find_the("filename"));
            $self->link(new Text($_)) for @lines;
        }
        if (my $s = $self->find_the("select")) {
            my ($from, $froms, $to, $tos) = 
                $s =~ /(after) '(.+)' and (before) '(.+)'/;
            my $sle = new Stuff("LineSelection", spec => $s);
            $sle->link($self);
            my $region_match = 0;
            for my $t ($self->linked("Text")) {
                $_ = $t->{text};
                if (!$region_match && /\Q$froms\E/ && !/select.+\Q$s\E/) {
                    $sle->link($t) unless $from eq "after";
                    $region_match = 1;
                }
                elsif ($region_match && /\Q$tos\E/) {
                    $sle->link($t) unless $to eq "before";
                    $region_match = 0;
                }
                elsif ($region_match) {
                    $sle->link($t);
                }
            }
        }
        if (my $us = $self->find_the("unselect")) {
            my $sle = $self->linked("LineSelection");
            $DB::single = 1;
            my @linked_text = $sle->linked("Text");
            for my $t (@linked_text) {
                if ($t->{text} =~ $us) {
                    $sle->unlink($t);
                }
            }
            $sle->{spec} = {
                select => $sle->{spec},
                unselect => $us,
            };
        }
    },
);
    be($tl);
    return $tl;
}

sub travel {
    my ($p, $body) = @_;
    my $lock = $p->match($body);
}

sub p {
    my $p = shift;
    if (ref $p) {
        new Pattern(ref $p => $p);
    }
    else {
        new Pattern(object => $p);
    }
}

start_timer();
my $clicks = 0;
until ($at_maximum_entropy) {
    $at_maximum_entropy = 1;
    $clicks++ > 21 && last;
    say "\nclick!\n";

    for my $todo ($wants->linked) {
        my $want = $todo->{want};
        if (ref $want eq "Pattern") {
            for my $wanted (grep { $want->match($_) } $junk->linked()) {
                be($todo, $wanted);
            }
        }
        elsif ($want ne "nothing") {
            be($todo);
        }
    }
}
say "$clicks clicks in ". show_delta();

# DISPLAY
exit;
my @ints = search("Junk->Text->Intuition");
my @texts = sort map { "$_->{0}" } @ints;
my %fin;
for my $text (uniq @texts) {
    my @ours = grep { $text eq "$_->{0}" } @ints;
    my @links = map { summarise($_->{1}, $_->{val}) } @ours;
    $fin{$ours[0]->{0}->{text}} = \@links;
}

displo($wants);
exit;


use Test::More "no_plan";
is_deeply(\%fin, Load(johnfaheys()), "John Fahey files discovered");

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

sub johnfaheys {
    return <<''
--- 
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	8115090	is size
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Meal.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	 	is reachable
../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition	1	probly relative	(?-xism:^\.\./)
  - Intuition	1	maybe relative	(?-xism:^(?!/))
  - Intuition		probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	9056908	is size
/home/steve/Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 04 - Some Summer Day.flac: 
  - Intuition	1	maybe filename	(?-xism:/)
  - Intuition		probly relative	(?-xism:^\.\./)
  - Intuition		maybe relative	(?-xism:^(?!/))
  - Intuition	1	probly absolute	(?-xism:^/)
  - Intuition	1	is reachable
  - Intuition	1	is file
  - Intuition	""	is dir
  - Intuition	1	is readable
  - Intuition	8115090	is size


}
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>scap!</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <script type="text/javascript" src="scope.js"></script></head>
    <body style="background: black"><ul></ul></body>
</html>
