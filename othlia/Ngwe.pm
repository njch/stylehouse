package Ngwe;
use strict;
use warnings;
use G;
our $A = {};

$A->{I}->{init} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $G->{T} = $G->{h}->($A,$C,$G,$T,"T",'w',$G->{T});
    $G->{way} = $G->{h}->($A,$C,$G,$T,"T",'w/way');
    sayyl "Gway: $_  $G->{way}->{$_}" for sort keys %{$G->{way}};
};
$A->{I}->{w} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$ar,@Me) = @M;
    my $I = $A->{I};
    sayyl "Got www $pin   with ".ki $ar;
    (my $fi = $pin) =~ s/\W/-/g;
    my $way = $G->{way}->{$fi} || die "No way: $fi";
    my $dige = $G->{way}->{$fi."_dige"} ||= slm 12, dig $way;
    sayre "OKAY: $dige: $way";
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    init: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: cfba26bfd017
        eg: Ngwe
      t: init
      "y": 
        cv: '0.1'
    w: 
      c: 
        from: Ngwe
      sc: 
        acgt: pin,ar
        args: A,C,G,T,pin,ar
        bab: ~
        code: I
        dige: 40b46fc8c5aa
        eg: Ngwe
      t: w
      "y": 
        cv: '0.1'

STEVE
