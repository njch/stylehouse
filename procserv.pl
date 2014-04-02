#!/usr/bin/perl
use strict;
use warnings;
open my $start, 'proc/start';
while my $command (<$start>) {
    if (my $pid = fork()) {
        open my $list, '>>proc/list';
        print $list "$$: $command\n";
        close $list;
        open STDOUT ">proc/$$.out";
        open STDERR ">proc/$$.err";
        open STDIN ">proc/$$.in";
        exec $command;
    }
}

