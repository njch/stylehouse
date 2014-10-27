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
sub wdump{Ghost::wdump(@_)}

sub new {
    my $H = shift;
    $H = $H->spawn0('H');
    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $T::H = $H;
    $W::H = $H;

    use lib 'lib';
    use Hostinfo;
    Hostinfo::lib_perc_H($H);
    $H->spawn0('A')->new($H);
    $H->{G} = $H->{A}->spawn(G => 'H');

    $H
}

sub spawn {
    my $H = shift;
    my $a = shift;
    my $u = $H->spawn0(@{$a->{r}});

    say "H spawning $u";
    if (ref $u eq 'A') {
        return $u->new($a->{i});
    }
    else {
        $H->spawn({i=>$u, r=>['A']});
        $a->{uA}->An($u);
        $u->{A}->Au($a->{uA});
    }
    shift @{$a->{r}};
    $u->new(@{$a->{r}});
}

sub spawn0 {
    my $H = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
    $u->{id} = mkuid();
    $u
}

sub spawn0 {
    my $H = shift;
    sub hitime {
        my $self = shift;
        return join ".", time, (gettimeofday())[1];
    }
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
    (mkuuid() =~ /^(\w+)-.+$/)[0];
}

sub mkuuid {
    UUID::generate(my $i);
    UUID::unparse($i, my $s);
    $s
}

'stylehouse'