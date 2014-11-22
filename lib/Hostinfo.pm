package Hostinfo;
use strict;
use warnings;
use Mojo::ByteStream 'b';
use Scriptalicious;
use Mojo::IOLoop;
use IO::Async::Loop::Mojo;
use IO::Async::FileStream;
use HTML::Entities;
use UUID;
use Scalar::Util 'weaken';
use Time::HiRes 'gettimeofday', 'usleep';
use Term::ANSIColor;
use Digest::SHA;
use File::Slurp;
use utf8;
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Data::Dumper;
use YAML::Syck;
use JSON::XS;
sub sha1_hex { Digest::SHA::sha1_hex(encode_utf8(shift)) }
sub enhash { Digest::SHA::sha1_hex(encode_utf8(shift)) }
sub dig { shift; Digest::SHA::sha1_hex(encode_utf8(shift)) }
use lib 'zrc/lib';
use Redis;

our $data = {};
${^WIDE_SYSTEM_CALLS} = 1;
sub new {
    my $pa = shift;
    my $p = shift;
    my $H = bless {%$p}, $pa;
    #$self->set('0', $self);
    $H->{for_all} = [];
    $H->{id} = make_uuid();
    
    lib_perc_H($H);
    
     #ouble
    $H->set('style', $H->{name}); # eventually to pick up a wormhole and etc.
    $H->set('sstyle', $H->{style}); # eventually to pick up a wormhole and etc
    
    $H->{G} = $H->TT($H)->G;
    
    $G::G0 = $H->TT("Ghost")->G("G");
    $G::G0->w('fresh_init');
    $G::G0->w('any_init');
    
    $H->{G}->w('fresh_init');
    $H->{G}->w('any_init');
    
    return $H
}
sub la {
    (`uptime` =~ /load average: (\S+),/)[0]
}


sub ind {
    "$_[0]".join "\n$_[0]", split "\n", $_[1]
}
sub fixutf8 {
  for (@_) {
    if (!is_utf8($_)) {
      $_ = decode_utf8($_); 
    }
  }
  return shift if @_ == 1;
}
sub slurp {
    my $self = shift;
    my $file = shift;
      open my $f, $file || die "O no $!";
    binmode $f, ':utf8';
    my $m = join "", <$f>;
    close $f;
    $m;
}
sub spurt {
    my $self = shift;
    my $file = shift;
    my $stuff = shift;
    say "Hostinfo: spurting $file (".length($stuff).")";
    $file = encode_utf8($file);
      open my $f, '>', $file || die "O no $!";
    binmode $f, ':utf8';
    print $f $stuff."\n";
    close $f;
}


1;

