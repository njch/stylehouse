package H;
our $H;
use strict;
use warnings;
use utf8;
use lib 'lib';
use lib 'l';
use A;
use C;
use G;
use H;
use W;
use UUID;
sub wdump{Ghost::wdump(@_);}

sub new {
    my $H = shift;
    $H = $H->spawn0('H');
    $A::H = $H;
    $C::H = $H;
    $G::H = $H;
    $H::H = $H;
    $W::H = $H;
    
    $H->spawn0('A')->new($H); 
    
    $H->{G} = $H->{A}->spawn($H, 'G');
    
    $H
}

sub spawn {
    my $H = shift;
    my $uu = shift;
    my $u = $H->spawn0(@_);
    
        $H->spawn($u, 'A') if ref $u ne 'A';
        return $u->new($uu, @_) if ref $u eq 'A';
    
    $u->new(@_);
}

sub spawn0 {
    my $H = shift;
    my $nb = shift;
    my $u = bless {}, $nb;
    $nb::H = $H;
    $u->{id} = mkuid(); # LEG .uuid
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