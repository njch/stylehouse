package Ise::Rob;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{robeg} = {
  'c' => {
   'from' => 'Ise/Rob'
     },
  'sc' => {
    'dige' => '9a0f4abe2423',
    'args' => 'A,C,G,T,s',
    'eg' => 'Ise::Rob',
    'bab' => undef,
    'code' => 'I',
    'acgt' => 's'
  },
  'y' => {
   'cv' => '0.1'
     },
  't' => 'robeg'
};
$A->{I}->{robeg} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    # look
    my $D = $s;
    my $eg = $D->{sc}->{eg};
    $eg =~ s/\//::/g;
    say "Robeg for $D->{t} looking in $eg";
    return 0; # TODO
};