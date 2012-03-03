#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use List::MoreUtils qw"uniq";
use v5.10;

my @one = ("../Music/Fahey/Death Chants, Breakdowns and Military Waltzes/Fahey, John - 08 - The Downfall Of The Adelphi Rolling Grist Mill.flac");

our $intuition = [];
our $learnings = [];
our $index = {};
our $at_total_entropy = 0;

my @givensif = split "\n", <<"";
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


while (defined($_ = shift @givensif)) {
    if (/^(\w+):/) {

        my $from = $1;
        # some leads

        until (!@givensif || $givensif[0] =~ /^\S/) {
            $_ = shift @givensif || last;
            s/^\s+// || die;

            my $cog =
                s/^\/(.+)\/ // ? qr"$1" :
                s/^\{(.+)\} // ? eval "sub { $1 }" :
                die;
            my ($cer, $to) = /^\s*(\w+)\s+(\w+)$/;
            $cer && $to || die;
            pat(
                from => $from,
                cer => $cer,
                to => $to,
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
}

sub pat {
    my $a = { @_ };
    push @$intuition, $a;

    # chuck names into an index
    for my $w ("from", "to", "mutex") {
        my @words = map { ref $_ eq "ARRAY" ? @$_ : $_ }
            $a->{$w} || next;
        map { push @{$index->{$_} ||= []}, $a } @words;
    }
}


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
sub metit {
    my $it = shift;
    grep { $_->{it} eq $it } @$learnings;
}
sub metitint {
    my ($it, $int) = @_;
    grep { $_->{int} eq $int } metit($it);
}

use Data::Walk;
sub analyse {
    my $it = shift || $_;
    if (ref $it eq "ARRAY") {
        walk \&analyse, @$it
    }
    else {
        my @meta = metit($it);
        if (!@meta) {
            if (ref \$it eq "SCALAR") {
                say "Met string!";
                met("string" => $it);
            }
            else {
                say "no idea how to start with $it";
            }
        }
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
