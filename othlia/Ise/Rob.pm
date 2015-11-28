package Ise::Rob;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub robeg {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
# look
my $D = $s;
my $eg = $D->{sc}->{eg};
$eg =~ s/\//::/g;
say "Robeg for $D->{t} looking in $eg";
return 0; # TODO
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    robeg: 
      c: 
        from: Ise/Rob
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: c713da69fba9
        eg: Ise::Rob
      t: robeg
      "y": 
        cv: '0.1'

STEVE
