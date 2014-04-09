#!/usr/bin/perl
use Scriptalicious;
my $ps = join"", grep /morbo/, `ps faux `;
$ps =~ /s\s+(\d+) +/ || say "nah cannot find";
`kill -KILL $1`;

