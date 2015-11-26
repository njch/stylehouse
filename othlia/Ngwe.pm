package Ngwe;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

$A->{I}->{airlock} = sub {

    sayre "Airlocked: ".$_[0];
    eval shift
};
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
    my @src = ($A,$C,$G,$T);
    my @got;
    for (qw'A C G T') {
        my $sr = shift @src;
        if (!exists $t->{$_}) {
            $t->{$_} = $sr;
            push @got, $_;
        }
    }
    unshift @k, @got if @got;
    sayyl "Got www $pin   with ".wdump [[@k],[@got]];
    (my $fi = $pin) =~ s/\W/-/g;
    my $way = $G->{way}->{$fi} || die "No way: $fi";
    say ":WAY: $way";
    my $dige = $G->{way}->{o}->{dige}->{$fi}
        || die "Not Gway not diges $fi: wayo: ".ki $G->{way}->{o};
    my $ark = join' ',@k;
    my $sub = $G->{dige_pin_ark}->{$dige}->{$pin}->{$ark} ||= do {
        my $C = {};
        $C->{t} = $pin;
        $C->{c} = {s=>$way,from=>"way"};
        $C->{sc} = {code=>1,noAI=>1,args=>join',',ar=>@k};
        my $code = $G->{h}->($A,$C,$G,$T,"won");
        $@ && die ":BEFORE $pin www $@";
        saybl "Ark: $C->{sc}->{args} \n\n $code";
        my $sub = $G->{airlock}->($code);
        $@ && die "www to $pin:\n$@";
        !$sub && die "www to $pin: no sub returned";
        $sub;
    };
    sayre "OKAY: $pin is $dige: $way \n\n\nAND SUB: $sub";
    $sub->($t,map{$t->{$_}}@k);
};
$A->{I}->{won} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;

    my $I = $A->{I};
    my $wast = $C->{t};
    $C->{t} =~ s/\W//sg;
    sayyl "Changed $wast --> $C->{t}" if $C->{t} ne $wast;
    my $ind = "    ";
    
    if ($C->{sc}->{acgt}) {
        # for ACGT+args in acgt, args take whole @_
        $C->{sc}->{args} ||= join',','A,C,G,T',grep{$_ ne '1'}$C->{sc}->{acgt};
        undef $C->{sc}->{code} if $C->{sc}->{code} eq '1';
        # the I that Cs all, it is indifferent to its current
        $C->{sc}->{code} ||= "I 1";
    }
    $C->{sc}->{got} && die ":Slooping";
    
        if ($C->{sc}->{code} =~ /\w+ \w+/) {
            $C->{sc}->{code} =~ /^(\w+) (\d+)$/ || die "wtfs code=$C->{sc}->{code}  ".ki$C;
            my ($K,$cv) = ($1,$2);
            $C->{sc}->{code} = $K;
            $cv = 0+("0.".$cv);
            sayyl "CHangting $K / $cv / $C->{t}   from $C->{y}->{cv}"
                if $cv ne $C->{y}->{cv} && $C->{y}->{cv} != 0.3;
            $C->{y}->{cv} = $cv;
        }
    
            my $ara = []; # ar ups and demand argsed
    
            if ($C->{sc}->{Td}) {
                my $Q;
                $Q->{path} = [split '/', $C->{sc}->{Td}];
                die if @{$Q->{path}} < 1;
    
                my $form = $C->{sc}->{Tdform} || 'nk/gk/wk';
                $Q->{atar} = [split '/', $form];
                @{$Q->{atar}} = @{$Q->{atar}}[0 .. (@{$Q->{path}}-1)];
    
                $Q->{onpa} = [split '/', 'T/d'];
                $Q->{caps} = {map{$_=>1}split',',$C->{sc}->{Tdarge}} if $C->{sc}->{Tdarge};
                # like rg but from $s
                $C->{sc}->{sr} && die "already sr";
                $C->{sc}->{sr} = join ',', grep{$_} d=>o=>v=>talk=> @{$Q->{atar}}, sort keys %{$Q->{caps}||{}};
                for my $sr (split ',', $C->{sc}->{sr}) {
                    die "mixo $sr" if $sr =~ /\W/;
                    push @$ara, $ind."my \$".$sr." = s\.$sr;";
                }
                $C->{sc}->{Ifs}->{Td} = $Q;
            }
    
            if ($C->{sc}->{v} && $C->{sc}->{v} ne '1') {
                my $v = $C->{sc}->{v};
                my ($nk,$gk) = $v =~ /^([tyc]|sc)(.*)$/;
                $nk||die"strv:$v";
                $C->{sc}->{nk} ||= $nk;
                $C->{sc}->{rg} ||= 1 if $C->{sc}->{nk} ne $nk;
                push @$ara, "    my \$".$nk." = C\.".$nk.";";
                if ($gk) {
                    $C->{sc}->{gk} ||= $gk;
                    my $gkk = $gk;
                    $gk = $C->{sc}->{gkis} if $C->{sc}->{gkis};
                    my $my = "my " unless $C->{sc}->{args} =~ /\bs\b/ && $nk eq 'c' && $gkk eq 's';
                    push @$ara, $ind."$my\$".$gk." = C\.".$nk."\.".$gkk.";";
                }
            }
    
            $C->{sc}->{rg} = $C->{sc}->{cg} if $C->{sc}->{cg};
            if (my $v = $C->{sc}->{rg}) {
                $v = '' if $v eq '1';
                my ($nk) = $C->{sc}->{v} =~ /^([tyc]|sc)(.*)$/;
                $nk ||= $C->{sc}->{nk} || 'c';
                $nk = 'c' if $C->{sc}->{cg};
                my @no = map {
                    my ($wnk,$wgk);
                    ($wnk,$wgk) = ($1,$2) if /^([tyc]|sc)(.*)$/;
                    $wnk ||= $nk;
                    $wgk ||= $_;
                    [$wnk,$wgk]
                } split /,/, $v;
                push @no, [$C->{sc}->{nk},$C->{sc}->{gk}] if $C->{sc}->{nk} && $nk ne $C->{sc}->{nk};
                for my $s (@no) {
                    push @$ara, $ind."my \$".$s->[1]." = C\.".$s->[0]."\.".$s->[1].";";
                }
            }
    
            if (my $args = $C->{sc}->{args}) {
                die "wonky $C->{t}   of ".ki $C if $C->{t} =~ /\W/;
                my $gl = "";
                my $und = "_";
                if ($args =~ s/^(A,C,G,T,)(?!s$)//) {
                    $gl .= $ind.'my ($A,$C,$G,$T,@M)=@_;'."\n";
                    $und = 'M';
                }
                my($sf,$sa);
                if ($C->{sc}->{subpeel}) { # runs, returns $T->{thing}
                    $sf = "(";
                    $sa = ')->($A,$C,$G,$T)';
                }
                # here some want their own I space
                # if I resolv backward winding pro-be
                # G pulls in I
                my $waytoset = "A\.I.".$C->{t}." = " unless $C->{sc}->{noAI};
                unless ($args eq '1') {
                    unshift @$ara, $ind."my \$I = A\.I;";
                    unshift @$ara, $ind."my (".join(',',map{'$'.$_}
                        split',',$args).',@Me) = @'.$und.";\n";
                }
                $C->{c}->{s} = $waytoset
                    .$sf
                    ."sub {\n"
                    .$gl
                    .join("\n",uniq(@$ara))."\n"
                    .join("\n",map{$ind.$_}split "\n", $C->{c}->{s})."\n"
                    ."}"
                    .$sa
                    .";";
                $C->{c}->{s} .= "A\.I\.d"."&An;\n" if $C->{t} eq 'An';
            }
            else {
                $C->{sc}->{subpeel}&&die"nonargs ha subpeel".ki$C
            }
    
    $G->{h}->($A,$C,$G,$T,"parse_babbl",$C->{c}->{s});
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    airlock: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: I
        dige: 07010c0626e9
        eg: Ngwe
      t: airlock
      "y": 
        cv: '0.1'
    init: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 9b8bb1946979
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
        dige: 5b24b61f43ba
        eg: Ngwe
      t: w
      "y": 
        cv: '0.1'
    won: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: b0a067f0aad7
        eg: Ngwe
      t: won
      "y": 
        cv: '0.1'

STEVE
