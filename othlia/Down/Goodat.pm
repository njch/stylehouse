package Down::Goodat;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

$A->{I}->{norp} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    sort { $I->{pwin}->($pin,$a) <=> $I->{pwin}->($pin,$b) } @Me;
};
$A->{I}->{pin} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$way,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    $I->{pwin}->($pin,$way);
};
$A->{I}->{pon} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,$way,$s,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    $I->{pwin}->($pin,$way,{et=>$s});
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
$A->{I}->{sorp} = sub {
    my ($A,$C,$G,$T,@M)=@_;
    my ($pin,@Me) = @M;
    my $I = $A->{I};
    $I->{pwin} || die "nopwin from pin";
    sort { $I->{pwin}->($pin,$a) cmp $I->{pwin}->($pin,$b) } @Me;
};
$A->{II} = Load(<<STEVE);
--- 
I: 
  "0.1": 
    norp: 
      c: 
        from: Down/Goodat
      sc: 
        acgt: pin
        args: A,C,G,T,pin
        bab: ~
        code: I
        dige: 49d8296634db
        eg: Down::Goodat
      t: norp
      "y": 
        cv: '0.1'
    pin: 
      c: 
        from: Down/Goodat
      sc: 
        acgt: pin,way
        args: A,C,G,T,pin,way
        bab: ~
        code: I
        dige: 4b3004b63abe
        eg: Down::Goodat
      t: pin
      "y": 
        cv: '0.1'
    pon: 
      c: 
        from: Down/Goodat
      sc: 
        acgt: pin,way,s
        args: A,C,G,T,pin,way,s
        bab: ~
        code: I
        dige: 76860c9adfeb
        eg: Down::Goodat
      t: pon
      "y": 
        cv: '0.1'
    pwin: 
      c: 
        from: Down/Goodat
      sc: 
        acgt: s
        args: pin,way,set
        bab: ~
        code: I
        dige: 04e675e3351c
        eg: Down::Goodat
      t: pwin
      "y": 
        cv: '0.1'
    sorp: 
      c: 
        from: Down/Goodat
      sc: 
        acgt: pin
        args: A,C,G,T,pin
        bab: ~
        code: I
        dige: 3ec4ecde0d62
        eg: Down::Goodat
      t: sorp
      "y": 
        cv: '0.1'

STEVE
