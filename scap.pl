#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use v5.10;

my @one = new Text("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $learnings = [];
our $at_total_entropy = 0;
# a bunch of Patterns will link themselves to $matches
our $matches = new Stuff();

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
    my $self = shift;
    push @{$self->{links}||=[]}, \@_;
}
sub linked {
    my $self = shift;
    my $spec = shift;
    map { $_->[0] } $self->links($spec);
}
sub links {
    my $self = shift;
    my $spec = shift;
    my $links = $self->{links};
    if (ref $spec) { # object
        grep { $_->[0] eq $spec } @$links
    }
    elsif ($spec) {
        grep { ref $_->[0] eq $spec } @$links
    }
    else {
        @$links
    }
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
    die if grep { $_ eq "string" } @{$self->{names}};
    $self;
}
sub match {
    my $self = shift;
    my $it = shift;

        $DB::single = 1;
    if ($self->{object}) {
        my $res = ref $it eq $self->{object};
        say "match ".($res?"PASS":"FAIL").": string";
        $res
    }
    elsif ($self->{names}) {
        my %res;
        for my $name (@{$self->{names}}) {
            my ($had, $uh) = ::it_is_to($it, $name);
            die ::Dump($uh) if $uh;
            $res{$name} = ($had && $had->{val} == 1) || 0;
        }
        my $res = (0 == grep { $res{$_} == 0 } keys %res);
        say "match ".($res?"PASS":"FAIL").": ". join "\t", %res;
        $res;
    }
}
} # $}}}
{ package Intuition;
# new
#   in => Pattern(to look for),
#   to => "word", the word describing a positive intuition
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

    say " looking: $self->{cer} $self->{to}...";
    my $cog = $self->{cog};
    my @val = 
        ref $cog eq "Regexp" ? $it =~ $cog :
        ref $cog eq "CODE" ? $cog->($it) :
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
            new Pattern (object => "Text") :
            new Pattern(names => [split /\s+/, $1]);

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
                to => $to,
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
    if (@_ == 2) {
        $val = 1;
    }
    unless (ref $int) {
        $int = { to => $int };
    }
    $int->link($it, $val);
    $at_total_entropy = 0;
}
sub meta_for {
    my $it = shift;
    $it->links("Intuition");
}
sub it_is_to {
    my ($it, $to) = @_;
    grep { $_->{to} eq $to } $it->linked("Intuition");
}

use Data::Walk;
sub analyse {
    my $it = shift || $_;

    METATRIEVE:
    my @meta = meta_for($it);

    if (!@meta && ref \$it eq "Text") {
        say "Met string!";
        met("string", $it);
        goto METATRIEVE;
    }

    # match 
    my @positive_intuitions = grep { $_->{val} } @meta;
    my @intuitions = map {
        $_->linked()
    } grep {
        $_->match($it)
    } $matches->linked("Pattern");
    say "ints: ".Dump(\@intuitions);

    $_->look($it) for @intuitions;

    # match our learnings for $it against $matches

}

until ($at_total_entropy) {
    $at_total_entropy = 1;
analyse(@one);
}


my $mbyit = {};
for my $e (@$learnings) {
    push @{$mbyit->{$e->{it}} ||= []}, [$e->{int}->{to}, $e->{val}];
}
say Dump($mbyit);

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
    my @nodes = map { summarise($_) } @$learnings;
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
