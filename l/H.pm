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
use H;
use T;
use W;
use UUID;
use Redis;
use File::Slurp;
use Time::HiRes 'gettimeofday', 'usleep';
use YAML::Syck;
use Data::Dumper;
use Term::ANSIColor;
use Encode qw(encode_utf8 decode_utf8 is_utf8);

sub new {
    my $H = shift;
    my $p = shift;
    $SIG{__WARN__} = sub {
        my $ing = shift;
        warn$ing unless $ing =~ /^Use of uninitialized/;
    };
    $H = $H->spawn0('H');
    $H->{h} = 1;
    $H->{dark} = 1;
    $H->{$_} = $p->{$_} for keys %$p;

    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $S::H = $H;
    $T::H = $H;
    $W::H = $H;

    use lib 'lib'; 
    use Hostinfo;
    Hostinfo::lib_perc_H($H);

    $G::T = {};
    $H->spawn0('A')->new($H);
    $H->{G} = $H->{A}->spawn(G => 'H');

    # is either G->subs or vortexed way, not a "root ghost" anymore but...
    $G::G0 = $Ghost::G0 = $H->{A}->spawn(G => 'G');
    $Ghost::G0->w('fresh_init');
    $Ghost::G0->w('any_init');

    delete $H->{dark};

    $H->{G}->w('fresh_init'); # art
    $H->{G}->w('any_init'); # art

    $H
}

sub enwebsocket {
    my $H = shift;
    my $mojo = shift;
    eval { 
      $H->{G}->w(websocket => { M => $mojo });
    };
        say "Eerror\n\n$@" if $@;
    $@ = "";
}

sub pi {
    my $H = shift;
    "H ! ";
}

sub spawn {
    my $H = shift;
    my $a = shift;
    my $u = $H->spawn0(@{$a->{r}});
    say "H spa $u->{id} ".$u->pi unless ref $u eq 'A' || ref $u eq 'C';

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
    die "Message contains \\n:\n$m\n\n" if $m =~ /\n/;
    my $a = {m => $m};
    $a->{cb} = $cb if $cb;
    $H->{G}->w(send_Elvis => $a);
}

sub throwlog {
    my $H = shift;
    my $what = shift;

    if (!$H->{mezthrowing}) {
        my $te = $@;
        $@ = "";
        $H->{mezthrowing} = 1;
        my $r = eval { $H->{G}->mess($what, [@_]) };
        undef $H->{mezthrowing};
        if ($@) {
            my $s = "G mess error while throwing a $what: $@";
            eval { $H->{G}->timer(0.1, sub { $H->error($s); }) };
            $@ = '';
        }
        $@ = $te;
        return if $r && $r eq "yep";
    }

    my @E;
    for my $b (@_) {
        if (ref $b eq "Way") {
            push @E, "Way: $b->{name}";
            push @E, ( map { " ` ".Ghost::ghostlyprinty("NOHTML", $_) } @{$b->{thing}});
            push @E, $b->{Error} if $b->{Error};
        }
        else {
            push @E, Ghost::ghostlyprinty("NOHTML", $b)
        }
    }
    my $error =
        [ hitime(), $H->stack(2), [@E] ];

    my @context = (
        grep { !/Ghost Ghost::__ANON__ |Ghost \(eval\)/ } @{$error->[1]},
    );
    @context = () if $what eq "Say" || $what eq "Info";
    my @f = @Ghost::F;
    for my $c (@context) {
        my $f = shift @f;
        say "$c ======== ". Ghost::gpty($f->{thing});
    }
    my $string = join("\n",
        @context,
        @{$error->[2]},
    );
    $string = "\n$string\n";
    print colored(ind("$what  ", $string)."\n", $what eq "Error"?'red':'green');
}

sub Say {
    my $H = shift;
    $H->throwlog("Say", @_);
}

sub Err {
    my $H = shift;
    $H->throwlog("Err", @_);
}

sub error {
    my $H = shift;
    $H->throwlog("Err", @_);
}

sub Info {
    my $H = shift;
    $H->throwlog("Info", @_);
}

sub info {
    my $H = shift;
    $H->throwlog("Info", @_);
}

sub snooze {
    my $H = shift;
    return Time::HiRes::usleep(shift || 5000);
}

sub ind {
    my $H = shift;
    my ($in, $thing) = @_;
    $thing = "" unless defined $thing;
    join "\n", map { "$in$_" } split "\n", $thing
}

sub wdump {
    my $H = shift;
    my $thing = shift;
    my $maxdepth = 3;
    if (@_ && $thing =~ /^\d+$/) {
        $maxdepth = $thing;
        $thing = shift;
    }
    $Data::Dumper::Maxdepth = $maxdepth;
    return join "\n", map { s/      /  /g; $_ } split /\n/, Dumper($thing);
}

sub JS {
    my $H = shift;
    my $js = shift;
    die "jno more ref to view" if ref $js;
    $js =~ s/\n/ /sg;
    $H->send($js);
}

sub la {
    my $H = shift;
    (`uptime` =~ /load average: (\S+),/)[0]
}

sub hitime {
    my $H = shift;
    return join ".", time, (gettimeofday())[1];
}

sub stack {
    my $H = shift;
    my $b = shift;
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
    my $H = shift;
    (mkuuid() =~ /^(\w+)-.+$/)[0];
}

sub mkuuid {
    my $H = shift;
    UUID::generate(my $i);
    UUID::unparse($i, my $s);
    $s
}

sub dig {
    my $H = shift;
    Digest::SHA::sha1_hex(encode_utf8(shift))
}

'stylehouse'