package Ngwe;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub airlock {
eval shift
};
sub h {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $y = $A->{I}->{$s} || do {
    sayre "Above for $s on $A->{talk} isssssssss $A->{up}->{talk}";
    $A->{up}->{I}->{$s} || die "No whay named $s on $A->{talk} or $A->{up}->{talk}: ".wdump 1, $A;
};
say "$A->{talk} h :  $s   < $C->{t}"
    unless $C->{t} =~ /^_/ || !$A->{J} || $A->{J}->{V} < 2;
$y->($A,$C,$G,$T,@Me);
};
sub init {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
$G->{T} = $G->{h}->($A,$C,$G,$T,"T",'w',$G->{T}||{});
$G->{way} = $G->{h}->($A,$C,$G,$T,"T",'w/way',{nonyam=>1});
};
sub w {
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
(my $fi = $pin) =~ s/\W/-/g;
my ($way,$dige);
my $D;
if ($D = $t->{__D}) {
    $dige = $D->{sc}->{dige} || die "wayzipin wasnt scdige: ".ki$D;
    $way = $D->{c}->{s};
    $way =~ s/^A\.I\.(\w+) = //s;
    $way =~ s/}A\.I\S+\n/\n/s if $D->{t} eq 'An'; # redoes, too trouble
}
else {
    $way = $G->{way}->{$fi} || die "No way: $fi";
    $dige = $G->{way}->{o}->{dige}->{$fi}
        || die "Not Gway not diges $fi: wayo: ".ki $G->{way}->{o};
}
my $ark = join',',@k;
my $code;
my $sub = $G->{dige_pin_ark}->{$dige}->{$pin}->{$ark} ||= do {
    my $C = {};
    $C->{t} = $pin;
    $C->{c} = {s=>$way,from=>"way"};
    $C->{sc} = {code=>1,noAI=>1,args=>"ar,$ark"};
    if ($D) {
        delete $C->{sc}->{args} unless $D->{sc}->{subpeel};
        $C->{c}->{from} = "I $D->{c}->{from}";
    }
    $code = $G->{h}->($A,$C,$G,$T,"won");
    $@ && die ":BEFORE $pin www $@";
    $SIG{__WARN__} = $G->{I}->{sigstackwarn} || die "NO sigstackwarn";
    my $sub = $G->{airlock}->($code);
    $@ && sayre "DED:\n".$code;
    $@ && die "way nicht compile: $pin:\n$@";
    !$sub && die "way nicht sub returned: $pin (no error tho)";
    $sub;
};
if ($D && !$D->{sc}->{subpeel}) {
    return $sub;
}
$sub->($t,map{$t->{$_}}@k);
};
sub won {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $wast = $C->{t};
$C->{t} =~ s/\W//sg;
my $ind = "";
$C->{sc}->{of} ||= $C->{sc}->{code};

if ($C->{sc}->{acgt}) {
    # for ACGT+args in acgt, args take whole @_
    $C->{sc}->{args} ||= join',','A,C,G,T',grep{$_ ne '1'}$C->{sc}->{acgt};
    $C->{sc}->{of} eq '1' && undef $C->{sc}->{of};
    # the I that Cs all, it is indifferent to its current
    $C->{sc}->{of} ||= "I";
}
$C->{sc}->{args} =~ s/[\+ ]/,/sgm;
$C->{sc}->{got} && die ":Slooping";

    if ($C->{sc}->{code} =~ /\w+ \w+/) { # LEG
        $C->{sc}->{code} =~ /^(\w+) (\d+)$/ || die "wtfs code=$C->{sc}->{code}  ".ki$C;
        my ($K,$cv) = ($1,$2);
        $C->{sc}->{of} = $K;
        $cv = 0+("0.".$cv);
        sayyl "CHangting $K / $cv / $C->{t}   from $C->{y}->{cv}"
            if $cv ne $C->{y}->{cv} && $C->{y}->{cv} != 0.3;
        $C->{y}->{cv} = $cv;
    }

        my $ara = []; # ar ups and demand argsed

        if ($C->{sc}->{Td}) { # onc populates
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
                push @$ara, "my \$".$sr." = s\.$sr;";
            }
            $C->{sc}->{Ifs}->{Td} = $Q;
        }

        if ($C->{sc}->{v} && $C->{sc}->{v} ne '1') {
            my $v = $C->{sc}->{v};
            my ($nk,$gk) = $v =~ /^([tyc]|sc)(.*)$/;
            $nk||die"strv:$v";
            $C->{sc}->{nk} ||= $nk;
            $C->{sc}->{rg} ||= 1 if $C->{sc}->{nk} ne $nk;
            push @$ara, $ind."my \$".$nk." = C\.".$nk.";";
            if ($gk) {
                $C->{sc}->{gk} ||= $gk;
                my $gkk = $gk;
                $gk = $C->{sc}->{gkis} if $C->{sc}->{gkis};
                my $my = "my " unless $C->{sc}->{args} =~ /\bs\b/ && $nk eq 'c' && $gkk eq 's';
                push @$ara, "$my\$".$gk." = C\.".$nk."\.".$gkk.";";
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
                next if $s->[1] eq $C->{sc}->{gk};
                push @$ara, "my \$".$s->[1]." = C\.".$s->[0]."\.".$s->[1].";";
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
            my $waytoset = "A\.I.".$C->{t}." = " unless $C->{sc}->{noAI} || $C->{sc}->{sub};
            my $sub = "sub".($C->{sc}->{sub} ? " $C->{t} " : ' ')."{\n";
            unless ($args eq '1') {
                unshift @$ara, "my \$I = A\.I;";
                unshift @$ara, "my (".join(',',map{'$'.$_}
                    split',',$args).',@Me) = @'.$und.";";
            }
            $C->{c}->{s} = $waytoset
                .$sf
                .$sub
                .$gl
                .join("",map{"$ind$_\n"} uniq(grep{$_}@$ara), split("\n", $C->{c}->{s}))
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
1: 
  "0.1": 
    airlock: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: 1
        dige: 5bd9a03b7bf4
        eg: Ngwe
        of: I
      t: airlock
      "y": 
        cv: '0.1'
    h: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: 1
        dige: 2dcdb2ffa81b
        eg: Ngwe
        of: I
      t: h
      "y": 
        cv: '0.1'
    init: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: 1
        dige: 7d5683de0f11
        eg: Ngwe
        of: I
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
        code: 1
        dige: e18cb9bc2fc6
        eg: Ngwe
        of: I
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
        code: 1
        dige: 69edd3fc9067
        eg: Ngwe
        of: I
      t: won
      "y": 
        cv: '0.1'

STEVE
