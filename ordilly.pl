#!/usr/bin/perl
use strict;
use warnings;

my $o = "viddy";
do_stuff();

if ("yes") {
    my $o = "blach";
    do_more_stuff();
}

sub do_stuff {
    print "rah!\n" for 1..3;
}

sub do_more_stuff {
    $o .= int rand 3;
    print "woo: ".$o;
}

1 && tidy_up();


sub tidy_up {
    undef $o;
}

