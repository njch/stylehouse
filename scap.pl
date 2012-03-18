#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use v5.10;

my @one = new Text("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $at_maximum_entropy = 0;
# a bunch of Patterns will link themselves to $matches
our $matches = new Stuff();
our @links;

# we have patterns leading to intuitions
# applied intuitions ($learnings) unlock more patterns...

{ package Stuff;
# base class for all things in this metaverse
# link  links stuff together
# links returns all links
# {{{
sub new {
    bless {}, __PACKAGE__;
}
sub link {
    push @links, [@_]; # self, other, ...
}
sub linked {
    my $self = shift;
    my $spec = shift;
    map { $_->[1] } $self->links($spec);
}
sub links {
    my $self = shift;
    my $spec = shift;
    return grep {
        ref $spec   ? $_->[1] eq $spec      # an object
        : $spec     ? ref $_->[1] eq $spec  # package name
        : 1
    } map {
        # ensure that $self is one, make it the first one
        $_->[0] eq $self 
            ? [@$_]
        : $_->[1] eq $self
            ? do {
                my @a = @$_;
                my @b = (shift(@a), shift(@a));
                [ reverse(@b), @a ]
            }
        : ()
    } @links # all the links in the whole metaverse
}
}
# }}}
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
    $matches->link($self);
    die if $self->{names} && grep { $_ eq "string" } @{$self->{names}};
    $self;
}
sub match {
    my $self = shift;
    my $it = shift;

    # TODO some logicator from cpan?
    if ($self->{object} && !$self->{names}) {
        my $res = ref $it eq $self->{object};
        say "match ".($res?"PASS":"FAIL").": string";
        $res
    }
    elsif ($self->{names}) {
        my %res;
        my %objects = map {$_->[1]->{name} => $_->[2]} $it->links($self->{object});
        for my $name (@{$self->{names}}) {
            $res{$name} = (exists $objects{$name} && $objects{$name} == 1);
        }
        my $res = (0 == grep { $res{$_} == 0 } keys %res);
        say "match ".($res?"PASS":"FAIL").": ". join "\t", %res;
        $res;
    } else { die }
}
} # $}}}
{ package Intuition;
# new
#   in => Pattern(to look for),
#   name => "word", the word describing a positive intuition
#   cer => is|probly|maybe|slight, security of knowledge
#           greater arrangements made out of uncertainties should be upgraded
#   cog => regex or code->($_) to test
# {{{
use base 'Stuff';
sub new {
    shift;
    my $self = bless {@_}, __PACKAGE__;
    $self->{in}->link($self);
}
sub look {
    my $self = shift;
    my $it = shift;

    return if $self->links($it); # already

    say " looking: $self->{cer} $self->{name}...";
    my $cog = $self->{cog};
    my $t = $it->text;
    my @val = 
        ref $cog eq "Regexp" ? $t =~ $cog :
        ref $cog eq "CODE" ? $cog->($t) :
        die;
    say @val ? "   @val" : "NOPE";
    @val = [] if @val > 1;
    ::met($self, $it, @val);
}
}
# }}}

# here we generate some intuitions and their matches 
# {{{


my @giv = split "\n", <<"";
string:
    /\// maybe filename
filename:
    /^\.\./  probly relative
    /^(?!/)/ maybe relative
    /^\//    probly absolute
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
            new Intuition(
                in => $in_match,
                name => $to,
                cer => $cer,
                cog => $cog,
            );
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

sub met {
    my ($int, $it, $val) = @_;
    say "intuited $int->{name}";
    if (@_ == 2) {
        $val = 1;
    }
    $int->link($it, $val);
    $at_maximum_entropy = 0;
}
sub meta_for {
    my $it = shift;
    $it->links("Intuition");
}

use Data::Walk;
sub analyse {
    my $it = shift || $_;

    # TODO this flows of entropy! make special thingy!
    map { $_->look($it) }
    map { $_->linked("Intuition") }
    grep { $_->match($it) }
        $matches->linked("Pattern");
}

until ($at_maximum_entropy) {
    $at_maximum_entropy = 1;
analyse(@one);
}


# DISPLAY

for my $it (@one) {
    for my $e ($it->links("Intuition")) {
        say $e->[1]->{name} ."\t\t". $e->[2];
    }
}

sub summarise {
    my $thing = shift;
    if (ref $thing eq "HASH") {
        return {
            id => "$thing",
            text => "$thing->{val} ".\$thing->{it}." $thing->{int}->{to}",
        }
    }
}

use Mojolicious::Lite;
use JSON::XS;
get '/' => 'index';
get '/ajax' => sub {
    my $self = shift;
    my $from = $self->param('from');
    my @nodes = map { summarise($_) } "balls";
    $self->render(text => encode_json(\@nodes));
};
#app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
    <head><title>scap!</title>
    <script type="text/javascript" src="jquery-1.7.1.js"></script></head>
    <script type="text/javascript" src="scope.js"></script></head>
    <body><%== content %></body>
</html>
