package Bun;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

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
    $_->{sc}->{Aref} = $1 if $_->{sc}->{call} =~ s/'?(HASH\(\S+\))'?, (?:'?(HASH\(\S+\))'?, ){3}//;
}
saybl "Stack:";
my $ind = " ";
my $le;
my $know;
$know->{h}->{'Ngwe'} = 1;
my $KnowA = $G::KA;
@stack = reverse @stack;
my @sum;
push @sum, shift @stack while @stack > 20;
my @fo;
unshift @stack, grep { push @fo, $_; $_->{t} =~ 'w' || $_->{t} eq 'h' && $_->{sc}->{call} =~ /^'loop'/
    || @fo > 2 && $fo[-2]->{t} eq 'h' && $fo[-2]->{sc}->{call} =~ /^'exood'/}
    @sum;
my ($A,$h);
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
    my $An = $KnowA->{$mayknow} if $mayknow;
    $A = $An if $An;
    my $tal = $An->{talk} if $An;
    $_->{c}->{tal} = $tal;
    if ($know->{$_->{t}}->{$_->{sc}->{pack}}) {
        $file = "<";
        undef $pack;
        $_->{sc}->{waspack} = $le->{sc}->{pack};
    }
    if ($le) {
        #undef $tal if $tal eq $le->{c}->{tal};
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
    if ($_->{t} eq 'h') {
        $called =~ /^"(.+?)"/;
        $h = $_->{c}->{h} = $1;
    }
    $tal = "$tal via" if $tal && $pack;
    say " ".$ind."$_->{t}\t$file :$line\t\t $called\t\t$tal $pack   ".ki($sc);
    #
    $le = $_;
}
$A && $h || return;

my $findII = sub {
    my $A = shift;
    ref $A->{t} eq 'CODE' ? $A->{J}->{A}->{II} : $A->{II} || die "wtf".wdump 2, $A;
};
my $findDt = sub {
    my ($II,$t) = @_;
    $II->{I}->{0.1}->{$t} || grep {$_->{t} eq $t} map{ values %$_ }map{ values %$_ }  map{$II->{$_}} grep {!/^(ooI|Ii)$/} keys %$II;
};
my ($D,@m) = $findDt->($findII->($A), $h);
my $l = $stack[-1];
if (!$D) {
    return sayre "NoD: $s->{t} $s->{talk}    $h    ".wdump 1, $A;
}
else {
    say "For $D->{t} $D->{y}->{cv}: ".ki $D->{sc};
    my $line = $l->{sc}->{line};
    $l->{sc}->{file} =~ /^\(eval/ || die "magcall ".wdump 3, $l;
    saybl "Call: $l->{sc}->{call}";
    my @lines = split "\n", $D->{c}->{s};
    $line--;
    my $i = 0;
    for (@lines) {
        $i == $line ? sayyl $_ :
        $i > $line - 6 &&
        $i < $line + 5 ? saygr $_ : 1;
        $i++;
    }
    sayre " !! !!";
}
};
sub sigstackwarn {
my ($s) = @_;
return if $s =~ /Deep recursion on subroutine/
    || $s =~ /masks earlier declaration in same/;
warn "Warndg: $s";
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    sigstackend: 
      c: 
        from: Bun
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: I
        dige: 3330de4302d2
        eg: Bun
        of: I
      t: sigstackend
      "y": 
        cv: '0.1'
    sigstackwarn: 
      c: 
        from: Bun
      sc: 
        acgt: s
        args: 1
        bab: ~
        code: I
        dige: 4d927cd17c44
        eg: Bun
        of: I
      t: sigstackwarn
      "y": 
        cv: '0.1'

STEVE
