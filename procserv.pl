#!/usr/bin/perl
use strict;
use warnings;
use Scriptalicious;
use Time::HiRes 'usleep';
use File::Slurp;

sub append {
    write_file("proc/list", {append => 1}, shift);
}

`cat /dev/null > proc/start`;
`cat /dev/null > proc/list`;
`rm proc/*.*` if glob('proc/*.*');

append("$$: $0");

my @old;
while (1) {
    my $i = 0;
    my @commands = `cat proc/start`;
    if (!@commands && @old) {
        @old = ();
    }
    for my $command (@commands) {
        if ($old[$i++]) {
            next;
        }
        push @old, $command;
        if (my $pid = fork()) {
            print "forked $pid\n";
        }
        else {
            append("$$: $command");
            chomp($command);
            local $|;
            print "Going to redirect output and start '$command' in $$\n";
            print "Err 1 $!\n" if $!;

            close STDOUT;
            open (STDOUT, ">>", "proc/$$.out") || die "out open fial: $!";
            print "Err 3 $!\n" if $!;

            close STDERR;
            open (STDERR, ">>proc/$$.err") || die "err open fial: $!";
            print "Err 4 $!\n" if $!;

            close STDIN;
            `touch proc/$$.in`;
            open (STDIN, "<", "proc/$$.in") || die "in open fial: $!";
            print "Err 5 $!\n" if $!;

            exec $command;
            print "Err 6 $!\n" if $!;
            print "after exec\n";
            exit;
        }
    }
    usleep(100);
}
