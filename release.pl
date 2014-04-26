
#!/usr/bin/perl
use strict;
use warnings;
my $version = "@ARGV";
my $name = "stylehouse-$version";
`mkdir $name`;
`cp -a CHANGES COPYING.txt ebuge.pl killbo.pl META.yml lib not proc procserv.pl public README.pod trampled_rose_lyrics ghosts wormholes ./$name/`;
