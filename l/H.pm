package H;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use feature 'say';
use lib 'l';
use A;
use C;
use G;
use J;
use R;
use UUID;
use File::Slurp;
use Time::HiRes 'gettimeofday', 'usleep';
use YAML::Syck;
use JSON::XS;
use Data::Dumper;
use Term::ANSIColor;
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Carp 'confess';
sub ddump { H::ddump(@_) }
sub wdump { H::wdump(@_) }

sub new {
    my $H = shift;
    my $p = shift;
    $SIG{__WARN__} = sub {
        my $ing = shift;
        warn$ing unless $ing =~ /^Use of uninitialized/;
    };
    $H = $H->spawn0('H');
    $H->{$_} = $p->{$_} for keys %$p;

    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $J::H = $H;
    $R::H = $H;

    $H->spawn0('A')->new($H);
    $H->{G} = $H->{A}->spawn(G => 'H');

    # is either G->subs or vortexed way, not a "root ghost" anymore but...
    $G::G0 = $H->{G};

    $H->{G} ->w("_load_ways_post", {S=>$H->{G}});

    $H
}

sub pi {
    my $H = shift;
    "H ! ";
}

sub spawn {
    my $H = shift;
    my $a = shift;
    my $u = $H->spawn0(@{$a->{r}});
    #say "H spa $u->{id} ". ref $u unless ref $u eq 'A' || ref $u eq 'C';

    if (ref $u eq 'A') {
        $u = $u->new($a->{i});
    }
    else {
        $H->spawn({i=>$u, r=>['A']});
        $a->{uA}->An($u);
        $u->{A}->Au($a->{uA});
        shift @{$a->{r}};
        $u = $u->new(@{$a->{r}});
    }

    $u
}

sub spawn0 {
    my $H = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    #$nb::H = $H;#TODO
    $u->{id} = $H->mkuid();
    $u
}

sub send {
    my $H = shift;
    my ($m, $cb) = @_;
    my $a = {m => $m};
    $a->{cb} = $cb if $cb;
    $H->{G}->w(send_Elvis => $a);
}

sub JS {
    my $H = shift;
    my $js = shift;
    die "jno more ref to view" if ref $js;
    $js =~ s/\n/ /sg;
    $H->send($js);
}

sub pub {
    my $H = shift;
    my ($S, $m, $ig) = @_;

    G::sayyl "H pub $S < ".G::slim(50,50,$m) if !$ig;
    $H->{db}->notify($S,$m);
}

sub djson {
    my $H = shift;
    my $m = shift;
    my $j;

    eval { $j = $H->json->decode(H::encode_utf8($m)) };
    die "JSON DECODE FUCKUP: $@\n\nfor $m\n\n\n\n" if $@;
    die "$m\n\nJSON decoded to ~undef~" unless defined $j;
    $j
}

sub ejson {
    my $H = shift;
    my $m = shift;
    $H->json->encode($m);
}

sub json {
    my $H = shift;
    $H->{json} ||= JSON::XS->new->allow_nonref;
}

sub fixutf8 {
    my $H = shift;
    for (@_) {
      if (!is_utf8($_)) {
        $_ = decode_utf8($_); 
      }
    }
    return shift if @_ == 1
}

sub snooze {
    my $H = shift;
    return Time::HiRes::usleep(shift || 5000);
}

sub ind {
    my $H = shift;
    my $in = shift;
    my $s = shift;
    join "\n",
         map { "$in$_" } split "\n", $s;
}

sub la {
    my $H = shift;
    (`uptime` =~ /load average: (\S+),/)[0]
}

sub hitime {
    my $H = shift;
    return join ".", gettimeofday();
}

sub stack {
    my $H = shift;
    my $b = shift;
    my $for = shift || 1024;
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

sub slurp {
    my $H = shift;
    scalar read_file(shift);
}

sub spurt {
    my $H = shift;
    write_file(shift, shift);
}

sub mkuid {
    (mkuuid() =~ /^(\w+)-.+$/)[0]
    .$H->{sdghih}++
}

sub mkuuid {
    UUID::generate(my $i);
    UUID::unparse($i, my $s);
    $s
}

sub dig {
    my $H = shift;
    Digest::SHA::sha1_hex(encode_utf8(shift))
}

9;

