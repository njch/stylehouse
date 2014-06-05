#!/usr/bin/perl
use Scriptalicious;
my $ps = join"", grep /morbo/, `ps faux `;
$ps =~ /s\s+(\d+) +/ || barf "nah cannot find";
`kill -KILL $1`;

