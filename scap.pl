#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use v5.10;

my @one = ("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $learnings = [];
our $at_total_entropy = 0;
# a bunch of Patterns will link themselves to $matches
our $matches = new Stuff();

# we have patterns leading to intuitions
# applied intuitions ($learnings) unlock more patterns...

{ package Stuff;
# base class for all things in this meta-universe
# link  links stuff together
# links returns all links
# {{{
sub new {
    bless {}, __PACKAGE__;
}
sub link {
    my $self = shift;
    push @{$self->{links}||=[]}, shift;
}
sub links { return @{shift->{links}} }
}
# }}}
{ package Pattern;
# new(names => @names) # primitive pattern matching
# are linked to $matches
# {{{
use base 'Stuff';
sub new {
    shift;
    my $self = bless {@_}, __PACKAGE__; # names => @names
    $matches->link($self);
    $self;
}
sub match {
    my $self = shift;
    my $it = shift;
    my %res;
    for my $name (@{$self->{names}}) {
        my ($had, $uh) = ::it_has($it, $name);
        die ::Dump($uh) if $uh;
        $res{$name} = ($had && $had->{val} == 1) || 0;
    }
    my $res = (0 == grep { $res{$_} == 0 } keys %res);
    say "match ".($res?"PASS":"FAIL").": ". join "\t", %res;
    $res;
}
} # }}}
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

    return if ::it_has($it, $self->{to}); # already

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

sub shift_until {
    my ($shift, $until) = @_;
    my @ret;
    until (!@$shift || $until->()) {
        push @ret, shift @$shift;
    }
    return @ret;
}

while (defined($_ = shift @giv)) {
    if (/^([\w ]+):/) {

        my $in_match = new Pattern(names => [split /\s+/, $1]);

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
    push @$learnings, {
        int => $int,
        it => $it,
        val => $val,
    };
    $at_total_entropy = 0;
}
sub meta_for {
    my $it = shift;
    grep { $_->{it} eq $it } @$learnings;
}
sub it_has {
    my ($it, $has) = @_;
    grep { $_->{int}->{to} eq $has } meta_for($it);
}

use Data::Walk;
sub analyse {
    my $it = shift || $_;

    METATRIEVE:
    my @meta = meta_for($it);

    if (!@meta && ref \$it eq "SCALAR") {
        say "Met string!";
        met("string", $it);
        goto METATRIEVE;
    }

    # match 
    my @positive_intuitions = grep { $_->{val} } @meta;
    my @matches = $matches->links();
    my @intuitions = map {
        $_->links()
    } grep {
        $_->match($it)
    } @matches;
    say Dump(\@intuitions);

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

