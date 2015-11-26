package Ise::Shelf;
use strict;
use warnings;
no warnings "uninitialized";
use G;
our $A = {};

$A->{I}->{A} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    ($A,my$up) = ({},$A);
    $A->{G} = $G; # for wiring from A (G/T/Hypo)
    $A->{up} = $up;
    $A->{mo} = $A;
    ($C,my$S) = ({},$C);
    $C->{c}->{J} = shift @$S;
    $C->{c}->{M} = $S->[1] if 2 == grep{ref$_ eq 'ARRAY'}@{$S}[0,1];
    $C->{c}->{N} = $C->{c}->{M} ? $S->[0] : $S;
    $A->{N} = [@{$C->{c}->{N}}];
    $A->{M} = [];
    $A->{J} = $C->{c}->{J} if $C->{c}->{J};
    $A->{J} || die "NOJ";
    
    $A->{fl} = $C->{c}->{fl} || {};
    $A->{am} = $s || die "unsame?";
    $A->{talk} = ($A->{J}->{le}&&"($A->{J}->{le}->{name})").$A->{J}->{name};
    {
    my $I = $A->{I} = {};
    my $II = $G->{w}->($A,$C,$G,$T,"collaspII",A=>$A);
    $I->{Ii} = $II->{Ii};
    say "$A->{talk} wants : $II->{Ii}";
    # split from R, dispatches of patches as I.$k = CODE
    # base exuder of self if no Ii resol
    %$I = (%$I,%{$G->{I}});
    $I->{Ii} = $II->{Ii};
    # throw in from R exact Ii, bits of Ii to I before t gets it
    if (my $re = delete $G->{drop}->{recycling}->{$A->{J}->{id}}->{$A->{am}}) {
        sayyl "Recyclo $A->{talk} --- $I->{Ii}  (".keys %$I;
        if ($re->{Ii} eq $I->{Ii}) {
            %$I = (%$I,%$re);
            $A->{cv} = 0.1;
        }
        else {
            sayre "Recycloped, Diff $I->{Ii}  <--  $re->{Ii}";
        }
    }
    $G->{h}->($A,$C,$G,$T,"An");
    $A->{t}->("1");
    $A->{t}->("11111") || warn "NO 1";
    }
    ($A,$C,$T)
};
$A->{I}->{Act} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $A->{s} = shift @{$A->{N}};
    if (ref $A->{s} eq 'HASH' && $A->{s}->{J} && $A->{s}->{mo} && $A->{s}->{talk}) {
        $A = $A->{s};
        $A->{mo} eq $s || die "$A->{talk}  mo $A->{mo}->{talk} not $s->{talk}";
        $C = $A->{C}||die"travcno $A->{talk}";
        $T = $A->{T} ||= {};
    }
    else {
        $A = {%$s};
        $A->{mo}->{ont} = $A; # keep
        $C = $A->{C} = {};
        $T = $A->{T} = {};
    }
    $T->{oM} = [];
    $G->{h}->($A,$C,$G,$T,"An");
    $A->{t}->("2");
    ($A,$C,$T)
};
$A->{I}->{An} = sub {
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
$A->{I}->{Sev} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $C = [Elvis=>''=>{J=>$s,Y=>'Pre',V=>'Duv'}];
    $C = [$s, $C];
    ($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"A",'Sev');
    $A->{I}->{scIfs} || die "NO scIfs: $A->{J}->{name}";
    $G->{h}->($A,$C,$G,$T,"loop");
};
$A->{I}->{h} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    my $y = $A->{I}->{$s} || die "No way named $s on $A->{talk}";
    $y->($A,$C,$G,$T,@Me);
};
$A->{I}->{loop} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    my $i;
    @{$A->{N}}||die"nois".wdump[$C,$A];
    while (@{$A->{N}}) { #
        $i++ > 5000 && die "Huge Indi";
        my ($A,$C,$T) = $G->{h}->($A,$C,$G,$T,"Act",$A);
        $T->{not}&&next;
        $A->{t}->("6");
        $T->{not}&&next;
        $G->{h}->($A,$C,$G,$T,"flywheels");
        $T->{not}&&next;
        $A->{t}->("78");
        $T->{not}&&next;
    }
    continue { $G->{h}->($A,$C,$G,$T,"z"); }
    $A->{t}->("8");
    $G->{h}->($A,$C,$G,$T,"recycle");
    ($A->{nj}) = values %{$A->{Js}} if $A->{Js} && keys %{$A->{Js}} == 1;
    if ($C->{c}->{M}) {
        @{$C->{c}->{M}} = () if $C->{c}->{M} eq $C->{c}->{N};
        my @un = uniq @{$A->{M}};
        die "ManyofsameM: ".wdump 3, $A->{M} if @{$A->{M}} > @un;
        push @{$C->{c}->{M}}, @{$A->{M}};
        $A
    }
    elsif ($C->{c}->{J}) {
        $G->{h}->($A,$C,$G,$T,"Mo",$C->{c}->{J},$A->{M},$C->{c}->{M}||[]);
    }
    else {
        die "noJMout";
    }
};
$A->{I}->{m} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $C = [$s,@Me];
    ($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"A",'Mo');
    $G->{h}->($A,$C,$G,$T,"loop");
};
$A->{I}->{n} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    $C = [$s,@Me];
    ($A,$C,$G,$T) = $G->{h}->($A,$C,$G,$T,"A",'In');
    $G->{h}->($A,$C,$G,$T,"loop");
};
$A->{I}->{recycle} = sub {
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
        dige: 812f6744f401
        eg: Ise::Shelf
      t: A
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
        dige: ebb51d1b7d0d
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
        dige: c338bf154937
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
        dige: 3154442f2daf
        eg: Ise::Shelf
      t: Sev
      "y": 
        cv: '0.1'
    h: 
      c: 
        from: Ise/Shelf
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: e6ec3c80aa41
        eg: Ise::Shelf
      t: h
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
        dige: 2cd19675052b
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
        dige: dcad850e9d3b
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
        dige: 156997e2ba28
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
        dige: 529c5fe2a27b
        eg: Ise::Shelf
      t: recycle
      "y": 
        cv: '0.1'

STEVE
