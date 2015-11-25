package Ise::Rob;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{robeg} = {
  'y' => {
   'cv' => '0.1'
     },
  'sc' => {
    'dige' => '9a0f4abe2423',
    'args' => 'A,C,G,T,s',
    'code' => 'I',
    'bab' => undef,
    'eg' => 'Ise::Rob',
    'acgt' => 's'
  },
  't' => 'robeg',
  'c' => {
   'from' => 'Ise/Rob'
     }
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