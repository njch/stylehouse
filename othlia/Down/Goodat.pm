package Down::Goodat;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{norp} = {
  'sc' => {
    'eg' => 'Down::Goodat',
    'acgt' => 'pin',
    'args' => 'A,C,G,T,pin',
    'bab' => undef,
    'code' => 'I',
    'dige' => '49d8296634db'
  },
  't' => 'norp',
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     }
};
$A->{I}->{norp} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    sort { $I->{pwin}->($pin,$a) <=> $I->{pwin}->($pin,$b) } @Me;
};
$A->{II}->{I}->{0.1}->{pin} = {
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     },
  'sc' => {
    'dige' => '4b3004b63abe',
    'code' => 'I',
    'eg' => 'Down::Goodat',
    'acgt' => 'pin,way',
    'bab' => undef,
    'args' => 'A,C,G,T,pin,way'
  },
  't' => 'pin'
};
$A->{I}->{pin} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$way,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    $I->{pwin}->($pin,$way);
};
$A->{II}->{I}->{0.1}->{pon} = {
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     },
  'sc' => {
    'code' => 'I',
    'dige' => '76860c9adfeb',
    'acgt' => 'pin,way,s',
    'eg' => 'Down::Goodat',
    'args' => 'A,C,G,T,pin,way,s',
    'bab' => undef
  },
  't' => 'pon'
};
$A->{I}->{pon} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$way,$s,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    $I->{pwin}->($pin,$way,{et=>$s});
};
$A->{II}->{I}->{0.1}->{pwin} = {
  'sc' => {
    'code' => 'I',
    'dige' => '04e675e3351c',
    'eg' => 'Down::Goodat',
    'acgt' => 's',
    'args' => 'pin,way,set',
    'bab' => undef
  },
  't' => 'pwin',
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     }
};
$A->{I}->{pwin} = sub {
    my ($pin,$way,$set,@Me) = @_;
    my $I = $A->{I};
    if (exists $way->{$pin}) {
          my $o = $way->{$pin};
        $way->{$pin} = $set->{et} if exists $set->{et};
        delete $way->{$pin} if $set->{de};
        return $o;
    }
    my @path = split /\/|\./, $pin;
    my $h = $way;
    my $last;
    for my $p (@path) {
        if (ref $h ne 'HASH' && ref $h ne 'G') {
            undef $last;
            undef $h;
            last;
        }
        $last = [$h,$p];
        $h = $h->{$p};
    }
    if ($last) {
        my ($he,$pi) = @$last;
        $he->{$pi} = $set->{et} if exists $set->{et};
        delete $he->{$pi} if $set->{de};
    }
    return $h if defined $h;
    
    return undef unless $pin =~ /\*/;
    die "sat rs findy $pin";
};
$A->{II}->{I}->{0.1}->{sorp} = {
  'c' => {
   'from' => 'Down/Goodat'
     },
  'y' => {
   'cv' => '0.1'
     },
  'sc' => {
    'eg' => 'Down::Goodat',
    'acgt' => 'pin',
    'args' => 'A,C,G,T,pin',
    'bab' => undef,
    'code' => 'I',
    'dige' => '3ec4ecde0d62'
  },
  't' => 'sorp'
};
$A->{I}->{sorp} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    sort { $I->{pwin}->($pin,$a) cmp $I->{pwin}->($pin,$b) } @Me;
};