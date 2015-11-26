package Down::GBabz;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

$A->{I}->{bitsof_babble} = sub {
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
$A->{I}->{parse_babbl} = sub {
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
    for my $l (split "\n", $s) {
        my $s = $l;
        if ($indbe) {
            if ($indbe eq 'nextind') {
                $s =~ /^(\s+)/;
                $indbe = qr/^$1/;
            }
            if ($s =~ $indbe) {
                $s =~ s/^(\s*)\.(\s*)$/$1$2/;
                push @s, $s;
                next;
            }
            else {
                undef $indbe;
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
        my $ze = qr/<<['"](\w*)['"]/;
        if ($s =~ /^(\s*)\S.*$ze/) {
            $indbe = $2 ?
                qr/^(?!\Q$1\E)/ # for <<'EOD' til ^EOD, etc
              : qr/^($1\s+|\s*$)/; # some space in or no nonspace = quote
            $s =~ s/$ze/'<<'.($1?"'$1'":'STEVE')/e;
            $inend = 'STEVE' if !$1;
        }
    
        # babable # expect closing brackets and insert J
        # eg Atime(2) = A.time->($J, 2)
        $s =~ s/(p.mwall)(\w*A)(\w+)\(/$1$2\.$3->(\$J, /smg;
        $s =~ s/(p.mwall)(\w*G)(\w+)\(/${1}G\.$3->(\$A,\$C,\$G,\$T, /smg;
        $s =~ s/(p.mwall)(\w*J)(\w+)\(/$1$2\.$3->(\$$2, /smg;
        $s =~ s/(p.mwall)(\w*M)(\w+)\(/${1}J\.m->(\$$2, /smg;
    
        # close side ourselves, likely to gobble suro if, etc.
        $s =~ s/(p.mwall)(u|n) (.+?);?$/${1}J\.$2->($3=>'');/smg;
        #$s =~ s/(p.mwall)(m) (\w+)\(/${1}J\.$3->(\$M, /smg;
    
        $s =~ s/I\.d\&(p.oint)/G\&$1/sgm;
        # lma quack $not->('tag');? from I.d&pui,$s
        $s =~ s/(p.oing|\w+)\&(p.oint)(,[^\s;]+)?(;)?/
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
        $s =~ s/(?:(?<=\W)|^)(?<!\\)([A-Za-z_]\w{0,3})((?:\.[\w-]*\w+)+)/"\$$1".join"",map {"->{$_}"} grep {length} split '\.', $2;/seg;
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
        from: Down/GBabz
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 1cb90e1d550a
        eg: Down::GBabz
      t: bitsof_babble
      "y": 
        cv: '0.1'
    parse_babbl: 
      c: 
        from: Down/GBabz
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: f6e8ec6adc67
        eg: Down::GBabz
      t: parse_babbl
      "y": 
        cv: '0.1'

STEVE
