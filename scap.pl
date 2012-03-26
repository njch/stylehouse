#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use Scriptalicious;
use v5.10;

my $junk = new Stuff();
my @one = map { $_->link($junk); $_ }
    map { new Text($_) }
    "../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac";

my $wants = new Stuff();
our $at_maximum_entropy = 0;
our @links;

{ package Stuff;
# base class for all things in this metaverse
# link  links stuff together
# links returns all links
# {{{
sub new {
    shift if $_[0] eq "Stuff";
    my $package = __PACKAGE__;

    if ($_[0]) {
        $package = shift;
        eval "package $package; use base 'Stuff';";
        die $@ if $@;
    }
    bless {@_}, $package;
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
{ package Action;
# new
# {{{
use base 'Stuff';
sub new {
    shift;
    my $self = Stuff::new(@_);
    if ($self->{want}) {
        $wants->link($self, $self->{want});
    }
    return $self
}
}
# }}}

our $intuitor = new Stuff("Intuitor");
$intuitor->link(
new Stuff(
    "Intuition",
#   name => "word", the word describing a positive intuition
#   cer => is|probly|maybe|slight, security of knowledge
#           greater arrangements made out of uncertainties should be upgraded
#   cog => regex or code->($_) to test
    does => sub {
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
    @val = [@val] if @val > 1;
    @val = (1) if @val == 0;
    
    say "intuited $self->{name}";
    $self->link($it, @val);
    $at_maximum_entropy = 0;
    },
));
$intuitor->link(
new Action(
"Intuit",
want => new Pattern(object => "Text"),
does => sub {
    my $self = shift;
    my $it = shift;

    unless ($self->linked("Intuition")) {
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
            my $int = new Intuition(
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
        map { $_->{does}->($_, $it) }
        map { $_->linked("Intuition") }
        grep { $_->match($it) }
        grep { $_->linked("Intuition") }
        map { $_->linked("Pattern") }
            $self->linked("Intuitor");
    }
},
));

start_timer();
my $clicks = 0;
until ($at_maximum_entropy) {
    $at_maximum_entropy = 1;
    $clicks++;
    for ($wants->links) {
        my ($wants, $action, $pattern) = @$_;
        map { $action->{does}->($action, $_) }
        grep { $pattern->match($_) }
            $junk->linked();
    }
}
say "$clicks clicks in ". show_delta();


# DISPLAY

for my $it ($junk->linked) {
    for my $e ($it->links("Intuition")) {
        say $e->[1]->{name} ."\t\t". $e->[2];
    }
}

sub summarise {
    my $thing = shift;
    my $text = "??? $thing";
    if (ref $thing eq "Text") {
        $text = $thing->text;
    }
    elsif (ref $thing eq "Intuition") {
        $text = "Intuition: $thing->{cer} $thing->{name}"
    }
    my $id;
    if (ref $thing) {
        ($id) = $thing=~ /\((.+)\)/;
    }
    my ($color) = $id =~ /(...)$/;
    return sprintf '<li id="%s" style="background-color: #%s">%s <a id="%s">-></a></li>', $id, $color, $text, $id;
}

sub junkilate {
    my $self = shift;
    my $point = $junk;
    if ($self && $self->param('from')) {
        my $from = $self->param('from');
        say "From: $from";
        for (@links) {
            if ($_->[0] =~ /$from/) {
                $point = $_->[0];
                last;
            }
            elsif ($_->[1] =~ /$from/) {
                $point = $_->[1];
                last;
            }
        }
        say "new point: $point";
        # from becomes Pattern?
    }
    my @nodes = map { summarise($_) } $point->linked;
    $self->render(text => join "\n", @nodes);
};
use Mojolicious::Lite;
use JSON::XS;
get '/' => 'index';
get '/ajax' => \&junkilate;
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
    <body><ul></ul></body>
</html>
