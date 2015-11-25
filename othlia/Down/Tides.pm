package Down::Tides;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{T} = {
  't' => 'T',
  'sc' => {
    'code' => 'I',
    'dige' => '0df41cdfdfbf',
    'acgt' => 's',
    'eg' => 'Down::Tides',
    'args' => 'A,C,G,T,s',
    'bab' => undef
  },
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Tides'
     }
};
$A->{I}->{T} = sub {
    my ($A,$C,$G,$T,$s,@Me) = @_;
    my $I = $A->{I};
    my $e = $G->{h}->($A,$C,$G,$T,"ti",'Wormhole');
    %$e = (%$e,%{$G->{T}}) if $G->{T};
    $G->{T} = $e;
    $G->{T}->{base} = 'w';
    $G->{T}
};
$A->{II}->{I}->{0.1}->{ti} = {
  't' => 'ti',
  'sc' => {
    'dige' => 'd2fe11f7eb4a',
    'code' => 'I',
    'bab' => undef,
    'args' => 'A,C,G,T,class',
    'acgt' => 'class',
    'eg' => 'Down::Tides'
  },
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Tides'
     }
};
$A->{I}->{ti} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($class,@Me) = @M;
    my $I = $A->{I};
    my %na;
    tie %na, $class, @Me;
    return \%na
};
$A->{II}->{Pack}->{0.3}->{Ghoz} = {
  'c' => {
   'from' => 'Down/Tides'
     },
  'y' => {
   'cv' => '0.3'
     },
  't' => 'Ghoz',
  'sc' => {
    'code' => 'Pack',
    'dige' => '228c7913fab6',
    'pack' => 'Ghoz',
    'bab' => undef,
    'eg' => 'Down::Tides'
  }
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
$A->{II}->{Pack}->{0.3}->{Wormhole} = {
  'c' => {
   'from' => 'Down/Tides'
     },
  'y' => {
   'cv' => '0.3'
     },
  'sc' => {
    'eg' => 'Down::Tides',
    'bab' => undef,
    'pack' => 'Wormhole',
    'dige' => 'ce649583e642',
    'code' => 'Pack'
  },
  't' => 'Wormhole'
};
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