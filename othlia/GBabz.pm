package GBabz;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub bitsof_babble {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $p;
$p->{alive} = qr/\$[\w]*[\w\->\{\}]+/;
$p->{dotha} = qr/[A-Za-z_]\w{0,3}(?:\.[\w-]*\w+)+/;
$p->{oing} = qr/$p->{alive}|$p->{dotha}|[-\w]{8,}/;
$p->{oint} = qr/[\w\$\/\->\{\}\*]*[\w\$\/\->\.\}\*]+/;
$p->{mwall} = qr/(?:= |if |unless |^\s*)/;
$p->{sur} = qr/ if| unless| for| when|,?\s*$|;\s*/;
$p
};
sub parse_babbl {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $p = $G->{bitsof_babble} ||= $G->{h}->($A,$C,$G,$T,"bitsof_babble");
# gone:
my $Jsrc = qr/(J\d*(?:\.\w+)?) (\w+)/;
my $Jlump = qr/(\S+) (\S+)\s+(\S.+)/;
$s =~ s/$p->{mwall}$Jsrc $Jlump$/$1.$2->("$3\\t$4" => $5);/smg;

# :
my @s;
my $indbe;
my $inend;
my $indun;
for my $l (split "\n", $s) {
    my $s = $l;
    if ($indbe) {
        if ($indun eq 'NEXT') {
            $s =~ /^(\s+)/ || die "Must Indunext:\n$s[-1]\n$s";
            $indun = $1;
        }
        if ($s =~ $indbe) {
            $s =~ s/^(\s*)\.(\s*)$/$1$2/;
            $s =~ s/^$indun//
                if defined $indun;
            push @s, $s;
            next;
        }
        else {
            undef $indbe;
            undef $indun;
            if ($s !~ /^\s*$/) {
                if ($inend) {
                    pop @s  if $s[-1] eq '';
                    push @s, $inend;
                }
            }
            else {
                $s = $inend if $inend;
            }
            undef $inend;
        }
    }
    my $angt = '<'.'<';
    my $ze = qr/$angt['"](\w*)['"]/;
    if ($s =~ /^(\s*)(?!#)\S.*$ze/) {
        if ($2) {
            # for <#<'EOD' til ^EOD, etc
            $indbe = qr/^(?!\Q$1\E)/;
        }
        else {
            $indbe = qr/^($1\s+|\s*$)/;
            $indun = 'NEXT';
            $s =~ s/$ze/$angt.($1?"'$1'":"'STEVE'")/e;
            $inend = 'STEVE' if !$1;
        }
    }

    #c babable # expect closing brackets and insert J
    # eg Atime(2) = $A->{time}->($J, 2)
    $s =~ s/($p->{mwall})(\w*A)(\w+)\(/$1$2\.$3->(\$J, /smg;
    $s =~ s/($p->{mwall})(\w*G)(\w+)\(/${1}G\.$3->(\$A,\$C,\$G,\$T, /smg;
    $s =~ s/($p->{mwall})(\w*J)(\w+)\(/$1$2\.$3->(\$A,\$C,\$G,\$T, \$$2, /smg;
    $s =~ s/($p->{mwall})(\w*[MN])(\w+)\(/${1}J\.m->(\$A,\$C,\$G,\$T, \$$2, /smg;

    # close side ourselves, likely to gobble suro if, etc.
    $s =~ s/($p->{mwall})(u|n) (.+?)(;| for .+?)?$/"${1}J\.$2->(\$A,\$C,\$G,\$T,$3=>'')".($4||';')/smeg;
    $s =~ s/($p->{mwall})(m) (.+?)(;| for .+?)?$/"${1}J\.$2->(\$A,\$C,\$G,\$T,\$M,$3=>'')".($4||';')/smeg;
    #$s =~ s/($p->{mwall})(m) (\w+)\(/${1}J\.$3->(\$M, /smg;
    $s =~ s/\$J->\{m\}->\(\$M,/J\.m->(\$A,\$C,\$G,\$T,\$M,/g;
    $s =~ s/\$J->\{n\}->\(\$J,/J\.n->(\$A,\$C,\$G,\$T,/g;
    $s =~ s/\$J->\{n\}->\(/J\.n->(\$A,\$C,\$G,\$T,/g;
    $s =~ s/\$I->\{d\}->\("([^\s"]+)"(?:(,[^\s\)]+))?\)/G\&$1$2/g;
    $s =~ s/\$G->\{w\}->\("([^\s"]+)", \{([^\)]+)?\}, \$G\)/\$G->{w}->(\$A,\$C,\$G,\$T,"$1",$2)/g;

    $s =~ s/I\.d\&($p->{oint})/G\&$1/g;
    # lma quack $not->('tag');? from $G->{h}->($A,$C,$G,$T,"pui",$s)
    $s =~ s/($p->{oing}|\w+)\&($p->{oint})(,[^\s;]+)?(;)?/
        my ($on,$p,$e,$t) = ($1,$2,$3,$4);
        my $in;
        ($on,$in) = ("G\.h",'$A,$C,$G,$T,')
            if $on eq 'G';
        my $s = $on."->($in\"$p\"$e)$t";
        $s = '$'.$s if $on !~ m{\.};
        $s
    /smge;
    # $sc>$k -> $sc->{$k}
    $s =~ s/($p->{oing})((?:\.>$p->{oing})+)/
        join '->', $1, map {'{"'.$_.'"}'}
        grep {$_} split m{\.>}, $2;
    /smge;
    #c Rw
    while ($s =~ /(Rw ($p->{oint})(?:(?!$p->{sur}) (.+?))?)$p->{sur}/gsm) {
        my ($old, $op, $oa) = ($1, $2, $3);
        my $g;
        $g ||= '$G';

        my $ne = ""; # hidden reverse
        $ne = $1 if $oa =~ s/($p->{sur})$//;

        my @n;
        my @m;
        # want to mix {m m m %$ar m m} whereever + is
        my $wanr = $oa =~ s/^\+ ?//;
        $wanr = 'stick' if $oa =~ s/^- ?//;
        for (split /\,| |\, /, $oa) {
            # sweet little pool... $J:geo etc
            if (/^\$((\w+(:|=))?\S+)$/) {
                my ($na, $fa, $wa) = ($1, $2, $3);
                if (!$fa) { # fake name, to ar
                    $fa = $na;
                }
                else {
                    $na =~ s/^\Q$fa\E//;
                    $fa =~ s/(:|=)$//;
                    if ($wa eq '=') {
                        $na = '"'.$na.'"';
                    }
                }
                $na = '$'.$na unless
                    $wa eq '=' || $na =~ /^\S+\.\S/;
                push @n, "$fa=>$na" ; # also avail a listy position
            }
            else {
                push @m, $_;
            }
        }
        unshift @n, '$ar' if (!@n || $wanr) && $wanr ne "stick";
        push @n, "m=>[".join(',',map{'"'.$_.'"'}@m).']'
            if @m;

        my @e;
        push @e, '"'.$op.'"';
        push @e, join(",",@n);
        my $en = join ",", @e;

        my $wa = $g.'->{w}->($A,$C,$G,$T,'.$en.')'.$ne;
        $s =~ s/\Q$old\E/$wa/          || die "Ca't replace $1\n\n $s";
    }

    # $sc->{k} -> $sc->{k};
    $s =~ s/([A-Za-z_]\w*)((?:\.\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/segm;
    # 
    $s =~ s/aft \{/acum \$F[0] => _after_do => sub {/sg;
    #

    push @s, $s;
}
push @s, $inend if $indbe && $inend;
$s = join "\n", @s;

$s;
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    bitsof_babble: 
      c: 
        from: GBabz
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: e489cdec53d0
        eg: GBabz
      t: bitsof_babble
      "y": 
        cv: '0.1'
    parse_babbl: 
      c: 
        from: GBabz
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 3df1317baaa9
        eg: GBabz
      t: parse_babbl
      "y": 
        cv: '0.1'

STEVE
