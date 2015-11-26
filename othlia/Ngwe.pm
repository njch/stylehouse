package Ngwe;
use strict;
use warnings;
no warnings "uninitialized";
use G;
our $A = {};

$A->{I}->{init} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $G->{T} = $G->{h}->($A,$C,$G,$T,"T",'w',$G->{T}||{});
    $G->{way} = $G->{h}->($A,$C,$G,$T,"T",'w/way',{nonyam=>1});
};
$A->{I}->{w} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    my $pin = $s;
    my ($t,@k);
    my @Eat = @Me;
    while (@Eat) {
        my $k = shift @Eat;
        if (ref $k) {
            my @or = map{$_=>$k->{$_}} sort keys %$k;
            unshift @Eat, @or;
        }
        else {
            push @k, $k;
            $t->{$k} = shift @Eat;
        }
    }
    sayyl "Got www $pin   with @k";
    (my $fi = $pin) =~ s/\W/-/g;
    my $way = $G->{way}->{$fi} || die "No way: $fi";
    my $dige = $G->{way}->{o}->{dige}->{$fi} || die "Not diges $fi: wayo: ".ki $G->{way}->{o};
    my $ark = join' ',@k;
    my $sub = $G->{dige_pin_ark}->{$dige}->{$pin}->{$ark} ||= do {
        my $C = {};
        $C->{t} = $way;
        $C->{c} = {s=>$way,from=>"way"};
        $C->{sc} = {code=>1,args=>join',',ar=>@k};
        my $code = $G->{h}->($A,$C,$G,$T,"won");
        #$G->{airlock}->($ar);
        'not'
    };
    sayre "OKAY: $pin is $dige: ".slim($way)." \n\n\nAND SUB: $sub";
};
$A->{I}->{won} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($v,@Me) = @M;
    my $I = $A->{I};
    my $s = $G->{h}->($A,$C,$G,$T,"parse_babbl",$C->{c}->{s});
    saybl $s;
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
        dige: a0ded370e768
        eg: Ngwe
      t: init
      "y": 
        cv: '0.1'
    w: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: c80956c13c8e
        eg: Ngwe
      t: w
      "y": 
        cv: '0.1'
    won: 
      c: 
        from: Ngwe
      sc: 
        acgt: v
        args: A,C,G,T,v
        bab: ~
        code: I
        dige: 9794186b50f5
        eg: Ngwe
      t: won
      "y": 
        cv: '0.1'

STEVE
