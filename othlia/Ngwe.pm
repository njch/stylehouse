package Ngwe;
use strict;
use warnings;
use G;
our $A = {};

$A->{I}->{w} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$ar,@Me) = @M;
    my $I = $A->{I};
    sayyl "Got www $pin   with ".ki $ar;
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    w: 
      c: 
        from: Ngwe
      sc: 
        acgt: pin,ar
        args: A,C,G,T,pin,ar
        bab: ~
        code: I
        dige: 742fad62afd4
        eg: Ngwe
      t: w
      "y": 
        cv: '0.1'

STEVE
