package Dump;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'app';

sub new {
    my $self = bless {}, shift;
    my %p = @_;
    $self->{cd} = $p{cd} || die;
    $self->app($p{app});
    my @etc = map { s/\n$//s; $_ } capture("ls", "-lh", $self->cd);
    my $text = new Texty($self, [@etc]);
    return $self;
}

1;
