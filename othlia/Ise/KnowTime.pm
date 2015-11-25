package Ise::KnowTime;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{carebowl} = {
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Ise/KnowTime'
     },
  'sc' => {
    'l' => '#c',
    'acgt' => 's,iii,x,xrd',
    'eg' => 'Ise::KnowTime',
    'args' => 'A,C,G,T,s,iii,x,xrd',
    'bab' => undef,
    'code' => 'I',
    'dige' => '9b257ed6b49a'
  },
  't' => 'carebowl'
};
$A->{I}->{carebowl} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($s,$iii,$x,$xrd,@Me) = @M;
    my $I = $A->{I};
    for my $ik (sort keys %$iii) {
        my $D = $iii->{$ik};
        if (my $nk = $D->{sc}->{nk}) {
            my $Ce = $I->{nF}->{C};
            die " SDIfC ".wdump 4,[$C, $Ce] if $C ne $Ce;
            next if !exists $C->{$nk};
            if (my $gk = $D->{sc}->{gk}) {
                next if !exists $C->{$nk}->{$gk};
            }
        }
        my $act;
        my $dont;
        if ($D->{sc}->{acgt} && $D->{sc}->{act}) {
            $act = 1;
            # acgtsubs can be defined at any cv
            # run themselves if act
            # usu. one receiver (Ci) and the rest scheme
            die "$D->{t} .act gets... $D->{sc}->{act}" if $D->{sc}->{act} ne '1';
            $dont = 1 if exists $A->{I}->{$D->{t}};
        }
        if (!$dont && $D->{sc}->{eg}) {
            $dont = $G->{h}->($A,$C,$G,$T,"robeg",$D);
        }
        # the $D->{s} should be perl expecting ACGT (which become robes to rob)
        if (!$dont) {
            my $paw = join"_",'',$I->{k},$I->{cv},$D->{t};
            $paw =~ s/\W//g;
            $G->{w}->("$paw", {A => $A, C => $C, G => $G, T => $T, __D => $D});
        }
        # most tiny ticks
        # this ind is all flywheel
        # it's a kind of unity that wants to be a block of code like this
        # and c
        my @is = $A->{s};
        @is = $G->{h}->($A,$C,$G,$T,"scIfs",$D->{sc}->{Ifs}) if $D->{sc}->{Ifs};
        @is || next;
        if ($act) {
            push @$xrd, [$I->{k},$ik];
            my $Ds = $x->{$I->{k}}->{$ik} ||= {};
            $Ds->{D} = $D;
            $Ds->{is} = \@is;
            $D->{sc}->{its} = @is;
        }
        # TreeD
        $s->{$I->{k}}->{$I->{cv}}->{$ik} = $D;
    }
};
$A->{II}->{I}->{0.1}->{ex} = {
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Ise/KnowTime'
     },
  'sc' => {
    'args' => 'A,C,G,T,i,K,cv,av',
    'bab' => undef,
    'acgt' => 'i,K,cv,av',
    'eg' => 'Ise::KnowTime',
    'code' => 'I',
    'dige' => 'e83fa1cf7861',
    'nois' => '#c'
  },
  't' => 'ex'
};
$A->{I}->{ex} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($i,$K,$cv,$av,@Me) = @M;
    my $I = $A->{I};
    # was $G->{w}->("SNat", {A => $A, C => $C, G => $G, T => $T, I => $I, i => $i, K => $K, cv => $cv});
    # baseism
    my $c = 0+("0.".$cv);
    my $Av = $av || $A->{cv};
    my $sp = $av ? " Flav $av (no $A->{cv})" : "";
    
    my $talk = "$A->{talk}: $K$sp $Av > $c --- $C->{t} ";
    
    my $aim = {$K=>1};
    if ($aim->{$A->{am}}) {
        $aim->{$_} = 1 for @{$A->{Isl}||[]};
        $aim->{I} = 1;
    }
    
    my $yv = {};
    # make K/cv/t -> cv/K/t
    for my $k (sort keys %$i) {
        my $ii = $i->{$k};
    
        next if $k eq 'Ii';
        next if $k eq 'ooI';
        ref $ii eq 'HASH' || die "weird $k=$ii";
    
        for my $vc (sort keys %$ii) {
            my $iii = $ii->{$vc};
            die'$k !0<$vc<1' unless $vc > 0 && $vc < 1;
            $yv->{$vc}->{$k} = $iii;
        }
    }
    
    # do stuff
    my $vb; # in fractions
    my $wasSubtle;
    for my $vc (sort keys %$yv) {
        my $is = $yv->{$vc};
        my $s = {};
        my $x = {};
        my $xrd = [];
    
        next if $vc <= $Av && $vc != $c;
        next if $vc > $c;
    
        # our  osc (stay in K per Subtle ness);
        my @iz = grep {
            $aim->{$_} || ($aim->{I} && ($A->{Iso}->{$_} || $I->{also}->{$_}))
        } sort keys %$is;
        next if !@iz;
    
        # decide inter cv wideness loop
        if ($wasSubtle) {
            undef $wasSubtle;
        }
        elsif ($vb && $vc > $vb && (
            @{$A->{N}} || @{$A->{mo}->{re}->{$vb}||[]}
            )) {
            # sincing, wide order
            # various others want to be around for only some of the process...
            sayre "$vb -> $vc  bump, ". @{$A->{N}} if $A->{J}->{V} > 1;
            $T->{Z}->{$vb} = 1;
            $A->{cv} = $vb; # so we dont wind up to 6 on the way out of t
            return $T->{not} = 1;
        }
    
        # pin down poles
        $I->{cv} = $vc;
        $I->{vb} = $vb;
        # draw curvles as spirals done
    
        for my $k (@iz) {
            my $iii = $is->{$k};
            $I->{k} = $k;
            $G->{h}->($A,$C,$G,$T,"carebowl",$s,$iii,$x,$xrd);
        }
        # suble
        my $se = $G->{w}->("TreeD", {s => $s, scby => "gro"}) 
            if $A->{J}->{V} > 1 && keys %$s;
        $c == 0.1 ? saygr $se : say $se if $se;
    
        my $o;
        ($o->{vc},$o->{vb}) = ($vc,$vb);
        $G->{h}->($A,$C,$G,$T,"exood",$o,$x,$xrd);
        ($vc,$vb) = ($o->{vc},$o->{vb});
        if ($o->{Subtle} && !$o->{nonSubtle}) {
            $wasSubtle = 1;
        }
    
        return if $T->{not};  # will &z, oseve
        return if delete $T->{whack};
    }
};
$A->{II}->{I}->{0.1}->{exood} = {
  'c' => {
   'from' => 'Ise/KnowTime'
     },
  'y' => {
   'cv' => '0.1'
     },
  't' => 'exood',
  'sc' => {
    'dige' => '23703206c8e8',
    'code' => 'I',
    'l' => '#c',
    'eg' => 'Ise::KnowTime',
    'acgt' => 'o,x,xrd',
    'bab' => undef,
    'args' => 'A,C,G,T,o,x,xrd'
  }
};
$A->{I}->{exood} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($o,$x,$xrd,@Me) = @M;
    my $I = $A->{I};
    for my $kik (@$xrd) {
        my ($k,$ik) = @$kik;
        $A->{Subtle} && $A->{Subtle}->{$k} ? $o->{Subtle}++ : $o->{nonSubtle}++;
        my $Ds = $x->{$k}->{$ik};
        my $D = $Ds->{D};
        for my $s (@{$Ds->{is}}) {
            $D->{sc}->{acgt} eq 's'||die "nonacgts".wdump $D;
            exists $A->{I}->{$D->{t}}||die "acgtI $D->{t} not up: ".wdump $A->{I};
    
            $T->{D} = $D;
            $G->{h}->($A,$C,$G,$T,"$D->{t}",$s);
    
            if (my $ut = $T->{ut}) {
                if ($ut->{matchTd}) {
                    my $d = $s->{d} || die "confuse";
                    $d->{od}->{s}->{T}->{q}->{$d->{e}->{k}} ||= $d;
                    $d->{od}->{s}->{T}->{m}->{$d->{e}->{k}} ||= $d
                        unless delete($T->{noTd});
                }
                else { die"utrowhat ".wdump 2, $ut }
            }
    
            # outwave: schools of many fish (not upcv if !@is)
            $o->{vb} ||= $o->{vc} if $D->{sc}->{v};
    
            last if $T->{not} || $T->{whack};
        }
        delete $T->{ut};
        last if $T->{not} || $T->{whack};
    }
};
$A->{II}->{I}->{0.1}->{t} = {
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Ise/KnowTime'
     },
  't' => 't',
  'sc' => {
    'eg' => 'Ise::KnowTime',
    'acgt' => 'K,cv,av',
    'bab' => undef,
    'args' => 'A,C,G,T,K,cv,av',
    'nois' => '#c',
    'dige' => '2307b8c71873',
    'code' => 'I'
  }
};
$A->{I}->{t} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($K,$cv,$av,@Me) = @M;
    my $I = $A->{I};
    ($K,$cv) = ($A->{am},$K) if !$cv && $K;
    $av = 0+("0.".$av) if $av;
    die "K$K cv$cv" unless $K && $cv;
    my $c = 0+("0.".$cv);
    my $Av = $av || $A->{cv};
    
    # adapt to much  mergey       extendo  rubble
    my $i = $G->{w}->("collaspII", {A => $A});
    die'difAvcol' if $Av ne ($av || $A->{cv});
    #
    my $ncv;
    my $re;
    my $dont;
    if ($Av < 0.6 || $c >= 0.7) {
        if ($c >= $Av) {
            $ncv = $c;
            $re = 1;
        }
        else {
            $re = 0;
            $dont = 1;
            say " deInc $Av - $cv $c";
        }
        die "pre bigger" if $cv < $Av;
    }
    else {
        if ($c < $Av) {
            if ($Av == 0.6) { # scoop up all on entering timezone
                $re = 1;
                $dont = 1; # or will II fall away
            }
            else {
                $re = 0;
                $dont = 1;
            }
        }
        elsif ($c == $Av) {
            $re = 1;
        }
        elsif ($c > $Av) { # and $c < 0.7, is a next time
            $T->{Z}->{$c} = 1;
            $re = 0;
            $dont = 1;
        }
        else {die"nof"}
    }
    undef $ncv if $av; # aux K
    my $was = $A->{cv};
    $dont || $G->{h}->($A,$C,$G,$T,"ex",$i,$K,$cv,$av);
    $A->{cv} = $ncv if defined $ncv && $A->{cv} == $was;
    $re;
};