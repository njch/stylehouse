package Down::Goodat;
use strict;
use warnings;
no warnings qw(uninitialized redefine);

use G;
our $A = {};

sub norp {
my ($A,$C,$G,$T,@M)=@_;
my ($pin,@Me) = @M;
my $I = $A->{I};
$I->{pwin} || die "nopwin from pin";
sort { $I->{pwin}->($pin,$a) <=> $I->{pwin}->($pin,$b) } @Me;
};
sub pin {
my ($A,$C,$G,$T,@M)=@_;
my ($pin,$way,@Me) = @M;
my $I = $A->{I};
$I->{pwin} || die "nopwin from pin";
$I->{pwin}->($pin,$way);
};
sub pon {
my ($A,$C,$G,$T,@M)=@_;
my ($pin,$way,$s,@Me) = @M;
my $I = $A->{I};
$I->{pwin} || die "nopwin from pin";
$I->{pwin}->($pin,$way,{et=>$s});
};
sub pwin {
my ($pin,$way,$set,@Me) = @_;
my $I = $A->{I};
if (exists $way->{$pin}) {
      my $o = $way->{$pin};
    $way->{$pin} = $set->{et} if exists $set->{et};
    delete $way->{$pin} if $set->{de};
    return $o;
}
my @path = split /\//, $pin;
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
sub sorp {
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
        dige: 4629e7c723bc
        eg: Down::Goodat
        of: I
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
        dige: 92bca4ae5de7
        eg: Down::Goodat
        of: I
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
        dige: 52a8b3012945
        eg: Down::Goodat
        of: I
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
        dige: eb1d6545728a
        eg: Down::Goodat
        of: I
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
        dige: 6a54267d00c0
        eg: Down::Goodat
        of: I
      t: sorp
      "y": 
        cv: '0.1'

STEVE
