package Ise::Shelf;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub A {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
($A,my$up) = ({},$A);
$A->{G} = $G; # for wiring from A (G/T/Hypo)
$A->{up} = $up;
$A->{mo} = $A;
$A->{am} = $s || die "unsame?";

$A->{C} = $C;
$A->{N} = [@{$C->{c}->{N}||[$C]}];
$A->{M} = [];
$A->{J} = $C->{c}->{J} if $C->{c}->{J};
$A->{J} || die "NOJ";
$A->{talk} = ($A->{J}->{le}&&"($A->{J}->{le}->{name})").$A->{J}->{name}."-".$A->{am};

$T = $A->{T} = {};
$G::KA->{"$A"} = $A;
$A->{fl} = $C->{c}->{fl} || {};
{
my $I = $A->{I} = {};
%$I = (%$I,%{$G->{I}});
my $II = $G->{w}->($A,$C,$G,$T,"collaspII",A=>$A);
$I->{Ii} = $II->{Ii};
# split from R, dispatches of patches as I.$k = CODE
# base exuder of self if no Ii resol
$I->{Ii} = $II->{Ii};
# throw in from R exact Ii, bits of Ii to I before t gets it
if (my $re = delete $G->{drop}->{recycling}->{$A->{J}->{id}}->{$A->{am}}) {
    if ($re->{Ii} eq $I->{Ii}) {
        %$I = (%$I,%$re);
        $A->{cv} = 0.1;
    }
    else {
        #sayre "Recycloped:  Diff $I->{Ii}  <--  $re->{Ii}";
    }
}
$G->{h}->($A,$C,$G,$T,"An");
$A->{t}->("1");
$A->{t}->("11111") || warn "NO 1";
}
($A,$C,$G,$T)
};
sub AN {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
$C = {};
($C->{c}->{J}, $C->{c}->{N}, $C->{c}->{M}) = (@Me);
ref $C->{c}->{N} eq 'ARRAY' || die "Not array CcN";
my $t = $C->{c}->{N}->[0];
$C->{c}->{N} = [$C->{c}->{N}] if defined $t && !ref $t; # C[] -> N[C[]]
ref $C->{c}->{M} || delete $C->{c}->{M};
$G->{h}->($A,$C,$G,$T,"A",$s)
};
sub Act {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $up = $s;
$s = shift @{$A->{N}};
if (ref $s eq 'HASH' && $s->{J} && $s->{mo} && $s->{talk}) {
    $A = $s;
    $A->{mo} eq $up || die "$A->{talk} re A mo $A->{mo}->{talk} notfrom $up->{talk}";
    $C = $A->{C}||die"travcno $A->{talk}";
    keys %$C == 4 || die "$A->{talk} carries wei ".wdump 3, $A;
    $T = $A->{T} ||= {};
    saybl "Resume has TNOT: $A->{talk} to $A->{cv}   with $C->{t}" if delete $T->{not};
}
else {
    $A = {%$up};
    $A->{mo}->{ont} = $A;
    $A->{s} = $s;
    $C = $A->{C} = {};
    $T = $A->{T} = {};
}
$T->{oM} = [];
$G->{h}->($A,$C,$G,$T,"An");
if ($A->{cv} < 0.2) {
    $A->{t}->("2");
    return (undef,undef,undef,{isnot=>1}) if $T->{isnot};
    ($C,$T) = ($A->{C},$A->{T});
    $G->{h}->($A,$C,$G,$T,"An");
}
($A,$A->{C},$G,$A->{T})
};
sub An {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
$A->{I} || die "GimeI";
$A->{note} = {}; # pinging csc
$A->{c} = sub { $G->{h}->($A,$C,$G,$T,"c",@_); };
$A->{e} = sub { $G->{h}->($A,$C,$G,$T,"e",@_); };
$A->{us} = sub { $G->{h}->($A,$C,$G,$T,"us",@_); };
$A->{t} = sub { $G->{h}->($A,$C,$G,$T,"t",@_); };
$A->{V} = sub { $A->{J}->{VV} && $A->{J}->{VV}->{$_[0]} || $A->{J}->{V} };
$A
};
sub Sev {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
$Me[0] ||= [Elvis=>''=>{J=>$s,Y=>'Pre',V=>'Duv'}];
$Me[1] ||= [];
($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"AN",'Sev',$s,@Me);
$A->{I}->{scIfs} || die "NO scIfs: $A->{J}->{name}";
$G->{h}->($A,$C,$G,$T,"loop");
};
sub d {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
die "USING I->d !".wdump 2, [$s,@Me];
};
sub loop {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $i;
@{$A->{N}}||die"nois".wdump(5, $C).wdump 2,$A;
while (@{$A->{N}}) { #
    $i++ > 5000 && die "Huge $A->{talk}";
    my ($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"Act",$A);
    next if delete $T->{isnot}; # zless
    for (1) {
        $T->{not}&&next;
        $A->{t}->("6");
        $T->{not}&&next;
        $G->{h}->($A,$C,$G,$T,"flywheels");
        $T->{not}&&next;
        $A->{t}->("78");
        $T->{not}&&next;
    }
    continue {
        $G->{h}->($A,$C,$G,$T,"z")
    }
}
$A->{cv} = 0.78;
$A->{t}->("8");
$G->{h}->($A,$C,$G,$T,"recycle");
($A->{nj}) = values %{$A->{Js}} if $A->{Js} && keys %{$A->{Js}} == 1;
$A->{bangdesk}->{main}->() if $A->{bangdesk}->{main};
if ($C->{c}->{M}) {
    @{$C->{c}->{M}} = () if $C->{c}->{M} eq $C->{c}->{N};
    my @un = uniq @{$A->{M}};
    die "ManyofsameM: ".wdump 3, $A->{M} if @{$A->{M}} > @un;
    push @{$C->{c}->{M}}, @{$A->{M}};
    $A
}
elsif ($C->{c}->{J} && $A->{am} eq 'In') {
    $G->{h}->($A,$C,$G,$T,"m",$C->{c}->{J},$A->{M},$C->{c}->{M}||[]) if @{$A->{M}};
}
else {
    die "noJMout $A->{am}";
}
};
sub m {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"AN",'Mo',$s,@Me);
$G->{h}->($A,$C,$G,$T,"loop");
};
sub n {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"AN",'In',$s,@Me);
$G->{h}->($A,$C,$G,$T,"loop");
};
sub recycle {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
return if $I->{recyttl}++ > 38;
$G->{drop}->{recycling}->{$A->{J}->{id}}->{$A->{am}} = $I;
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    A: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 18cd98643529
        eg: Ise::Shelf
      t: A
      "y": 
        cv: '0.1'
    AN: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: e06917e4c9af
        eg: Ise::Shelf
      t: AN
      "y": 
        cv: '0.1'
    Act: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: c929109024ff
        eg: Ise::Shelf
      t: Act
      "y": 
        cv: '0.1'
    An: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 6d795f329e50
        eg: Ise::Shelf
      t: An
      "y": 
        cv: '0.1'
    Sev: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 3d64a2c76c68
        eg: Ise::Shelf
      t: Sev
      "y": 
        cv: '0.1'
    d: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 9dac59c7fcb5
        eg: Ise::Shelf
      t: d
      "y": 
        cv: '0.1'
    loop: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 63c2c41c7989
        eg: Ise::Shelf
      t: loop
      "y": 
        cv: '0.1'
    m: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: b8c09c07b8f9
        eg: Ise::Shelf
      t: m
      "y": 
        cv: '0.1'
    "n": 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: a990ff0f831f
        eg: Ise::Shelf
      t: 'n'
      "y": 
        cv: '0.1'
    recycle: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: d76511e31fad
        eg: Ise::Shelf
      t: recycle
      "y": 
        cv: '0.1'

STEVE
