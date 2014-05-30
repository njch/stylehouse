#!/usr/bin/perl
use strict;
use warnings;
use Scriptalicious;
use Time::HiRes 'usleep';
use File::Slurp;

sub append {
    write_file("proc/list", {append => 1}, shift);
}

`rm -rf proc` if -e 'proc';
`mkdir proc`;
`cat /dev/null > proc/start`;
`cat /dev/null > proc/list`;

append("$$: $0\n");

my $i = 0;
while (1) {
    my @commands = `cat proc/start`;
    $i = 0 if @commands < $i;
    splice(@commands, 0, $i);
    say "HAve ".@commands.'coammdn';

    for my $command (@commands) {
        $i++;
        say "A command";
        if (my $pid = fork()) {
            print "forked $pid: $command\n";
        }
        else {
            my ($styleparent, $command) = $command =~ /^(\d+): (.+)$/;
            append("$$: $command\n");
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
            exit;
        }
    }
    usleep(290000);
}
