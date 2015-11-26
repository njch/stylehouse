package G;
use strict;
use warnings;
no warnings "uninitialized";

our $A = {};
# two annoying dependencies 
use Mojo::IOLoop::Stream;
use Mojo::IOLoop;
use Mojo::UserAgent;
#use Mojo::SMTP::Client;
use File::Slurp qw(read_file write_file);
use JSON::XS;
our $JSON = JSON::XS->new->allow_nonref;
our $JSONS = JSON::XS->new->allow_nonref;
$JSONS->canonical(1); # sorts hashes
our $IDI = 1; # hash
use YAML::Syck qw(Dump DumpFile Load LoadFile);
use Data::Dumper; 
use Storable 'dclone';
use Carp;
use UUID;

use Time::HiRes qw(gettimeofday usleep);
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use List::MoreUtils qw(natatime uniq);
use POSIX qw'ceil floor';
use Math::Trig 'pi2';

use HTML::Entities;
use Unicode::UCD 'charinfo';
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Term::ANSIColor;
our @F; # is Ring re subs from below 

our $MAX_FCURSION = 240;
our $RADIAN = 1.57079633;
our $NUM = qr/-?\d+(?:\.\d+)?/;

# going...
our $db = 0;
our $gp_inarow = 0;
our $swdepth = 5;
our $G0;
our $Ly;
our $_ob = undef;


# ^ curves should optimise away, accord ion

# to dry up

use Exporter 'import';
our @EXPORT = qw(read_file write_file Dump DumpFile Load LoadFile dclone gettimeofday usleep first max maxstr min minstr reduce shuffle sum natatime uniq ceil floor pi2 charinfo encode_utf8 decode_utf8 is_utf8 snooze dig ind acum slm slim sjson ejson djson zjson mkuuid mkuid flatline hitime hexbe hexend unico k2 kk ki saybl saygr sayg sayre sayyl say saycol wdump ddump inter F_delta stack fwind);


sub snooze {
return Time::HiRes::usleep((shift || 500) * 10);

}
sub dig {
Digest::SHA::sha1_hex(encode_utf8(shift))

}
sub ind {
"$_[0]".join "\n$_[0]", split "\n", $_[1]

}
sub acum {
my ($n, $y, $c) = @_;
push @{$n->{$y}||=[]}, $c;

}
sub slm {
my $s = slim(@_);
$s =~ s/\.\.(\.|\d+)$//;
$s

}
sub slim {
my ($f,$t,$c) = @_;
($f,$t,$c) = (40,40,$f) if defined $f && !defined $t && !defined $c;
($f,$t,$c) = ($f,$f,$t) if defined $t && defined $f && !defined $c;
$c = ($c=~/^(.{$t})/s)[0]."..".(length($c) - $f) if length($c) > $f;
$c

}
sub sjson {
my $m = shift;
$JSONS->encode($m);

}
sub ejson {
my $m = shift;
$JSON->encode($m);

}
sub djson {
my $m = shift;
my $j;

eval { $j = $JSON->decode(encode_utf8($m)) };
die "JSON DECODE FUCKUP: $@\n\nfor $m\n\n\n\n" if $@;
die "$m\n\nJSON decoded to ~undef~" unless defined $j;
$j

}
sub zjson {
my $n = shift;
if ($n->{J}) {
    $n = {%$n};
    delete $n->{J};
}
sjson($n)

}
sub mkuuid {
UUID::generate(my $i);
UUID::unparse($i, my $s);
$s

}
sub mkuid {
(mkuuid() =~ /^(\w+)-.+$/)[0]
.$IDI++

}
sub flatline {
map { ref $_ eq "ARRAY" ? flatline(@$_) : $_ } @_

}
sub hitime {
return join ".", gettimeofday();

}
sub hexbe {
my@h = map { sprintf('%x', int($_)) } @_;
wantarray ? @h : join'',@h;

}
sub hexend {
$_[0] =~ /([0-f])?([0-f])?([0-f])?$/;
map { hex($_) } $1, $2, $3;

}
sub unico {
my ($int, $wantinfo) = @_;
my $h = sprintf("%x", $int);
my @s = eval '"\\x{'.$h.'}"';
push @s, charinfo($int) if $wantinfo;
wantarray ? @s : shift @s

}
sub k2 {
ki(1, shift);

}
sub kk {
my ($s,$lum) = @_;
$lum ||= 1;
my $d = (3 - $lum);
my $lim = 150 - (150 * ($d / 3));
!ref $s || "$s" !~ /(ARRAY|HASH)/ && return "!%:$s";
join ' ', map {
    my $v = $s->{$_};
    $v = "~" unless defined $v;
    ref $v eq 'HASH'
        ? "$_=".($lum ?  "{ ".slim($lim,ok($v,$lum-1))." }" : "$v")
    : ref $v eq 'ARRAY'
        ? "$_=\@x".@$v
        : "$_=".slim(150,"$v")
} sort keys %$s;

}
sub ki {
my ($re,$ar,$d) = @_;
$d++;
if ($re !~ /^\d+$/ && !$ar) {
    $ar = $re;
    $re = 2;
}
if (!ref $ar || "$ar" !~ /(HASH)/) {
    my $s = "!%:$ar";
    $s =~ s/\n/\\n/g;
    return slim(30,$s);
}
#
my $lim = 150 - (150 * ($d / 3));
my @keys = sort keys %$ar;
@keys = ('name') if $ar->{name} && $ar->{bb};
@keys = ('t','y','c','sc') if $ar->{t} && $ar->{y} && $ar->{c} && $ar->{sc};
if ($ar->{cv} eq '0.3' && $ar->{aspace} eq '0.6') {
      my $t = {map{$_=>1}qw'aspace in out ov pcv space spc mu i u thi'};
    @keys = grep{!$t->{$_}}@keys;
}
join ' ', map {
      my $k = $_;
    my $v = $ar->{$k};
    $v = "~" unless defined $v;
    ref $v eq 'HASH' ? do {
        $v->{bb} && $v->{name} ?
            ($d > 1 && ($v->{name} eq 'Duv' || $v->{name} eq 'Pre') ? "$_:$v->{name}"
          : $d > 1 && $_ eq 'at' ? "at:".slim(5,$v->{t})
          :
            "$_={@".$v->{name}."&".slm(3,$v->{id})."@}"
          )
        : 
              "$_=".($re?"{ ".slim($lim,ki($re-1,$v,$d))." }":"$v")
    }
    : ref $v eq 'ARRAY' ?
          do "$_=\@x".@$v.(@$v < 9 && slim(19, join", ",@$v))
        : "$_=".slim(150,"$v")
} @keys;

}
sub saybl {
saycol(bright_blue => @_) 

}
sub saygr {
saycol(green => @_)

}
sub sayg {
saycol(bright_green => @_)

}
sub sayre {
saycol(red => @_)

}
sub sayyl {
saycol(bright_yellow => @_)

}
sub say {
saycol(white => @_)

}
sub saycol {
my $colour = shift;
print colored(join("\n", @_,""), $colour);
wantarray ? @_ : shift @_

}
sub wdump {
my $thing = shift;
my $maxdepth = 3;
if (@_ && $thing =~ /^\d+$/) {
    $maxdepth = $thing;
    $thing = shift;
}
$Data::Dumper::Maxdepth = $maxdepth;
my $s = join "\n", map { s/      /  /g; $_ } split /\n/, Dumper($thing);
$s =~ s/^\$VAR1 = //;
$s =~ s/^    //gm;
$s;

}
sub ddump {
my $thing = shift;
my $ind;
return
    join "\n",
    grep {
        1 || !( do { /^(\s*)hostinfo:/ && do { $ind = $1; 1 } }
        ...
        do { /^$ind\S/ } )
    }
    "",
    grep !/^       /,
    split "\n", Dump($thing);

}
sub inter {
my $thing = shift;
my $ki = ki($thing);
$ki =~ s/^\s+//;
$F[1]->{inter} .= " -{".$ki."}\n";

}
sub F_delta {
my $now = hitime();
my $then = $F[0]->{hitime};
my $d = sprintf("%.3f",$now-$then);
$d = $d<1 ? ($d*1000).'ms' : $d.'s';

}
sub stack {
my $b = shift;
my $for = shift || 169;
$b = 1 unless defined $b;
my @from;
while (my $f = join " ", (caller($b))[0,3,2]) {
    last unless defined $f;
    my $surface = $f =~ s/(Mojo)::Server::(Sand)Box::\w{24}/$1$2/g
        || $f =~ m/^Mojo::IOLoop/
        || $f =~ m/^Mojolicious::Controller/;
    $f =~ s/(MojoSand\w+) (MojoSand\w+)::/$2::/;
    push @from, $f;
    last if $surface;
    last if !--$for;
    $b++;
}
return [@from];

}
sub fwind {
my $way = shift;
      my $point = shift;
      return $way->{$point} if exists $way->{$point};
      my @path = split /\/|\./, $point;
      my $h = $way;
      for my $p (@path) {
          $h = $h->{$p};
          unless ($h) {
              undef $h;
              last;
          }
      }
      return $h if defined $h;

      return undef unless $point =~ /\*/;
      die "sat rs findy $point";

}
sub wayup {
my $G = shift;
my $way = read_file(shift);
$G->{way} = Load($way); 

}