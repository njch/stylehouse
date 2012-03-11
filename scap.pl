#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use v5.10;

my @one = ("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $learnings = [];
our $at_total_entropy = 0;
our $matches = new Stuff();

# we have patterns leading to intuitions
# applied intuitions ($learnings) unlock more patterns...

{ package Stuff;
sub new {
    bless {}, __PACKAGE__;
}
sub link {
    my $self = shift;
    push @{$self->{links}||=[]}, shift;
}
sub all { return @{shift->{links}} }
}
{ package Pattern;
use base 'Stuff';
sub new {
    shift;
    my $self = bless {@_}, __PACKAGE__; # names => @names
    $matches->link($self);
    $self;
}
}
{ package Intuition;
use base 'Stuff';
sub new {
    shift;
    my $self = bless {@_}, __PACKAGE__;
    $self->{in}->link($self);
}
}

# here we generate a basic pyramid scheme of matches and data
# {{{
# pat() is the out tray

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
            my $cog =
                s/^\/(.+)\/ // ? qr"$1" :
                s/^\{(.+)\} // ? eval "sub { $1 }" :
                die;
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
        pat(
            mutex => \@mutex,
        );
    }
    else { die $_ }
}

# }}}

sub met {
    my ($int, $it, $val) = @_;
    if (@_ == 2) {
        $val = 1;
    }
    unless (ref $int eq "HASH") {
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

use Data::Walk;
sub analyse {
    my $it = shift || $_;

    my @meta = meta_for($it);

    if (!@meta && ref \$it eq "SCALAR") {
        say "Met string!";
        met("string", $it);
    }

    my @positive_intuitions = grep { $_->{val} } @meta;
    # match our learnings for $it against $matches

        else {
            # learned things, ideas we got TO
            my %tos = map { $_ => 1 }
                map { $_->{int}->{to} }
                grep { $_->{val} }
                grep { defined $_->{int}->{to} } @meta;
            # intuitions involving these things somehow

            my @relvnt = grep { $_->{from} && $tos{$_->{from}} } @$intuition;

            for my $r (@relvnt) {
                if ($tos{$r->{to}}) {
                    say "already got $r->{to}";
                    next
                }
                say " - $r->{cer} $r->{to}...";
                my $cog = $r->{cog};
                my @val = 
                    ref $cog eq "Regexp" ? $it =~ $cog :
                    ref $cog eq "CODE" ? $cog->($it) :
                    die;
                say @val ? "   @val" : "NOPE";
                @val = [] if @val > 1;
                met($r, $it, @val);
            }
        }
    }
}

until ($at_total_entropy) {
    $at_total_entropy = 1;
}

analyse(@one);
analyse(@one);
analyse(@one);
analyse(@one);

my $mbyit = {};
for my $e (@$learnings) {
    push @{$mbyit->{$e->{it}} ||= []}, [$e->{int}->{to}, $e->{val}];
}
say Dump($mbyit);

