package Ngwe;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub airlock {
eval shift
};
sub init {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
$G->{T} = $G->{h}->($A,$C,$G,$T,"T",'w',$G->{T}||{});
$G->{way} = $G->{h}->($A,$C,$G,$T,"T",'w/way',{nonyam=>1});
};
sub sigstackend {
my $s = $@;
local $@;
eval { G::confess( '' ) };
my @stack = split m/\n/, $@;
shift @stack for 1..2;
if ($stack[-1] =~ /^\s+Mojo::IOLoop::start/) {
    pop @stack until $stack[-1] !~ /Mojo|eval/;
}
@stack = map{[$_, /^\s*(?:eval \{\.\.\.\} |([^\(\s]+)::([^\s\(]+?)\((.+)\) )called at (\S+|\(eval \S+\)) line (\d+)$/]} @stack;
@stack = map{[$_->[2],'',{l=>$_},{pack=>$_->[1],call=>$_->[3],file=>$_->[4],line=>$_->[5]}]}@stack;
@stack = map{{t=>$_->[0],y=>{},c=>$_->[2],sc=>$_->[3]}}@stack;
#s/\t/  /g for @stackend;
# write on the train thats about to derail
for (@stack) {
    my $i = -1;
    $_->{sc}->{Aref} = $1 if $_->{sc}->{call} =~ s/'(HASH\(\S+\))', (?:'(HASH\(\S+\))', ){3}//;
}
saybl "Stack:";
my $ind = " ";
my $le;
my $know;
$know->{h}->{'Ise::Shelf'} = 1;
my $KnowA = $G::KA;
@stack = reverse @stack;
my @sum;
push @sum, shift @stack while @stack > 10;
my @fo;
unshift @stack, grep { push @fo, $_; $_->{t} =~ 'w' || $_->{t} eq 'h' && $_->{sc}->{call} =~ /^'loop'/
    || @fo > 2 && $fo[-2]->{t} eq 'h' && $fo[-2]->{sc}->{call} =~ /^'exood'/}
    @sum;
for (@stack) {
    my $sc = {%{$_->{sc}}};
    my $called = delete $sc->{call};
    $called =~ s/'((?:(.)(ASH|RRAY)|(\S+))\(\S+\))'/$2||$4/seg;
    my $file = delete $sc->{file};
    $file =~ s/^$main::Bin\///;
    $file =~ s/^othlia\/// && $file =~ s/\//::/s && $file =~ s/\.pm$//;
    my $pack = delete $sc->{pack};
    my $fi = join "/", split '::', $pack;
    if ($file =~ /$fi\.pm$/) {
        $file = $pack;
        undef $pack;
    }
    my $line = delete $sc->{line};
    my $mayknow = delete $sc->{Aref};
    my $Ano = $KnowA->{$mayknow} if $mayknow;
    my $tal = $Ano->{talk} if $Ano;
    $_->{c}->{tal} = $tal;
    if ($know->{$_->{t}}->{$_->{sc}->{pack}}) {
        $file = "<";
        undef $pack;
        $_->{sc}->{waspack} = $le->{sc}->{pack};
    }
    if ($le) {
        undef $tal if $tal eq $le->{c}->{tal};
        $ind .= " " if $_->{sc}->{pack} ne $le->{sc}->{pack} &&
            !$le->{sc}->{waspack} || $le->{sc}->{waspack} ne $_->{sc}->{pack};
        undef $file if $file eq $le->{sc}->{pack} || $file eq $le->{sc}->{waspack};
        undef $pack if $pack eq $le->{sc}->{pack};
    }
    if (!$file && $pack) {
        $file = $pack;
        undef $pack;
    }
    if ($file =~ /^\(eval (\d+)/) {
        $file = ($pack&&"$pack > ")."?".$1;
        undef $pack;
    }
    $_->{t} = '?' if $_->{t} eq '__ANON__';
    $tal = "$tal via" if $tal && $pack;
    say " ".$ind."$_->{t}\t$file :$line\t\t $called\t\t$tal $pack   ".ki($sc);
    #
    $le = $_;
}
};
sub sigstackwarn {
my ($s) = @_;
return if $s =~ /Deep recursion on subroutine/
    || $s =~ /masks earlier declaration in same/;
warn "Warndg: $s";
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
#say "Way $A->{talk} $pin" unless $pin =~ /^_/;
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
        dige: 5bd9a03b7bf4
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
        dige: 7d5683de0f11
        eg: Ngwe
      t: init
      "y": 
        cv: '0.1'
    sigstackend: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: I
        dige: 61129a2e6fe2
        eg: Ngwe
      t: sigstackend
      "y": 
        cv: '0.1'
    sigstackwarn: 
      c: 
        from: Ngwe
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: I
        dige: 4d927cd17c44
        eg: Ngwe
      t: sigstackwarn
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
        dige: a9554cbe8e6a
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
        dige: 3aa14dcacf23
        eg: Ngwe
      t: won
      "y": 
        cv: '0.1'

STEVE
