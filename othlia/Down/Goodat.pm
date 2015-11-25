package Down::Goodat;
use strict;
use warnings;
use G;
our $A = {};

$A->{II}->{I}->{0.1}->{norp} = {
  'c' => {
   'from' => 'Down/Goodat'
     },
  't' => 'norp',
  'sc' => {
    'acgt' => 'pin',
    'dige' => '49d8296634db',
    'args' => 'A,C,G,T,pin',
    'bab' => undef,
    'eg' => 'Down::Goodat',
    'code' => 'I'
  },
  'y' => {
   'cv' => '0.1'
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
  'c' => {
   'from' => 'Down/Goodat'
     },
  'y' => {
   'cv' => '0.1'
     },
  't' => 'pin',
  'sc' => {
    'code' => 'I',
    'bab' => undef,
    'eg' => 'Down::Goodat',
    'args' => 'A,C,G,T,pin,way',
    'dige' => '4b3004b63abe',
    'acgt' => 'pin,way'
  }
};
$A->{I}->{pin} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$way,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    $I->{pwin}->($pin,$way);
};
$A->{II}->{I}->{0.1}->{pon} = {
  't' => 'pon',
  'sc' => {
    'acgt' => 'pin,way,s',
    'eg' => 'Down::Goodat',
    'bab' => undef,
    'code' => 'I',
    'args' => 'A,C,G,T,pin,way,s',
    'dige' => '76860c9adfeb'
  },
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     }
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
    'dige' => '04e675e3351c',
    'code' => 'I',
    'bab' => undef,
    'eg' => 'Down::Goodat',
    'args' => 'pin,way,set',
    'acgt' => 's'
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
  't' => 'sorp',
  'sc' => {
    'acgt' => 'pin',
    'bab' => undef,
    'eg' => 'Down::Goodat',
    'code' => 'I',
    'args' => 'A,C,G,T,pin',
    'dige' => '3ec4ecde0d62'
  },
  'y' => {
   'cv' => '0.1'
     },
  'c' => {
   'from' => 'Down/Goodat'
     }
};
$A->{I}->{sorp} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    sort { $I->{pwin}->($pin,$a) cmp $I->{pwin}->($pin,$b) } @Me;
};