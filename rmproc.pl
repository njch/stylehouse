#!/usr/bin/perl
use strict;
use warnings;
`cat /dev/null > proc/start`;
`cat /dev/null > proc/list`;
`rm proc/*.*` if glob('proc/*.*');
