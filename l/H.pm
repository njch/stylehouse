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
use W;
use UUID;
sub wdump{Ghost::wdump(@_)}

sub new {
    my $H = shift;
    $H = $H->spawn0('H');
    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $W::H = $H;
    
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

'stylehouse'