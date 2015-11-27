package Down::Tides;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub T {
my ($A,$C,$G,$T,$s,@Me) = @_;
my $I = $A->{I};
my $e = $G->{h}->($A,$C,$G,$T,"tie",'Wormhole',{base=>$s},@Me);
say "Made Wormhole: ".ki $e->{o};
return $e;
};
sub tie {
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
    use G;
    use Tie::Hash;
    our @ISA = qw(Tie::ExtraHash);
    sub TIEHASH {
        my $class = shift;
        my %o;
        %o = (%o, %{$_}) for @_;
        return bless [{},\%o], $class;
    }
    sub STORE {
        my ($e,$k,$v) = @_;
        my ($s,$o,@o) = @$e;
        die "Storign o " if $k eq 'o';
        if ($o->{nonyam}) {
            $o->{dige}->{$k} = slm 12, dig $v unless ref $v;
        }
        $s->{$k} = $v;
    }
    sub FETCH {
        my ($e,$k,$v) = @_;
        my ($s,$o,@o) = @$e;
        return $o if $k eq 'o';
        $s->{$k} || STORE($e,$k, do {
            my $il = join('/', grep{defined} $o->{dir}, $k);
            my $f = $o->{base}.'/'.$il;
            if (-d $f) {
                my %Di;
                tie %Di, 'Wormhole';
                my $di = \%Di;
                $di->{o} =
                $di->{base} = $o->{base};
                $di->{dir} = $il;
                $di
            }
            elsif (-f $f) {
                print "Loading $f ...\n";
                $o->{nonyam} ?
                scalar read_file($f)
                :
                LoadFile($f);
            }
            else {
                die "Wormhole sens nothing: $f";
            }
        });
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
        dige: b2ec9119560f
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
        dige: 26a6bbbfb025
        eg: Down::Tides
      t: tie
      "y": 
        cv: '0.1'

STEVE
