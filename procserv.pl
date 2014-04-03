#!/usr/bin/perl
use strict;
use warnings;
use Scriptalicious;
use Time::HiRes 'usleep';
use File::Slurp;
my @old;
`cat /dev/null > proc/start`;
`cat /dev/null > proc/list`;
`rm proc/*.*` if glob('proc/*.*');
while (1) {
    my $i = 0;
    for my $command (`cat proc/start`) {
        if ($old[$i++]) {
            next;
        }
        push @old, $command;
        if (my $pid = fork()) {
            print "forked $pid\n";
        }
        else {
            write_file("proc/list", {append => 1}, "$$: $command");
            chomp($command);
            print "Going to redirect output and start '$command' in $$\n";
            local $/;
            print "Err 1 $!\n" if $!;
            open(my $out, '>&', STDOUT);
            print $out "Err 2 $!\n" if $!;

            close STDOUT;
            `touch proc/$$.out`;
            open STDOUT, ">>proc/$$.out" || die "out open fial: $!";
            print $out "Err 3 $!\n" if $!;

            close STDOUT;
            `touch proc/$$.err`;
            open STDERR, ">>proc/$$.err" || die "err open fial: $!";
            print $out "Err 4 $!\n" if $!;

            close STDIN;
            `touch proc/$$.in`;
            open STDIN, "<", "proc/$$.in" || die "in open fial: $!";
            print $out "Err 5 $!\n" if $!;

            exec $command;
            print $out "Err 6 $!\n" if $!;
            exit;
        }
    }
    usleep(100);
}

