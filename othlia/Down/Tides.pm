package Down::Tides;
use strict;
use warnings;
use G;
our $A = {};

$A->{I}->{T} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    my $e = $G->{h}->($A,$C,$G,$T,"tie",'Wormhole');
    %$e = (%$e,%{$G->{T}}) if $G->{T};
    $G->{T} = $e;
    $G->{T}->{base} = 'w';
    $G->{T}
};
$A->{I}->{tie} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($class,@Me) = @M;
    my $I = $A->{I};
    my %na;
    tie %na, $class, @Me;
    return \%na
};
{
    package Ghoz; #
    use Tie::Hash;
    our @ISA = qw(Tie::ExtraHash);
    sub TIEHASH {
        my $class = shift;
        my $sto = bless [{},@_], $class;
        $sto
    }
    sub FETCH {
        my ($s,$k) = @_;
        my ($st,@o) = @$s;
        return $st->{$k} if exists $st->{$k};
        option:
        for my $o (@o) {
            if (my $in = $o->{inp}) {
                my $v = $o->{o};
                for my $i (@$in,$k) {
                    exists $v->{$i} || next option;
                    $v = $v->{$i};
                }
                return $v;
            }
            else {
                die "Hwoto climb a ".G::ki $o;
            }
        }
    }
}
{
    package Wormhole;
    use Tie::Hash;
    use YAML::Syck;
    our @ISA = qw(Tie::StdHash);
    sub FETCH {
        my ($s,$k) = @_;
        $s->{$k} ||= $k eq 'dir' ? return : do {
            my $d = $s->{dir};
            my $il = join('/', grep{defined} $d, $k);
            my $f = $s->{base}.'/'.$il;
            if (-d $f) {
                my %Di;
                tie %Di, 'Wormhole';
                my $di = \%Di;
                $di->{base} = $s->{base};
                $di->{dir} = $il;
                $di
            }
            elsif (-f $f) {
                print "Loading $f ...\n";
                LoadFile($f);
            }
            else {
                die "Wormhole sens nothing: $f";
            }
        };
    }
}
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    T: 
      c: 
        from: Down/Tides
      sc: 
        acgt: s
        args: A,C,G,T,s
        bab: ~
        code: I
        dige: 459d5b4d0e67
        eg: Down::Tides
      t: T
      "y": 
        cv: '0.1'
    tie: 
      c: 
        from: Down/Tides
      sc: 
        acgt: class
        args: A,C,G,T,class
        bab: ~
        code: I
        dige: 308c97386cb4
        eg: Down::Tides
      t: tie
      "y": 
        cv: '0.1'

STEVE
