package Dumpo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;

    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->set('Dumpo', $self);

    my $dump = $self->hostinfo->dump("dontsay");
    my $text = new Texty($self, [split("\n", $dump)], 'hodu');
    return $self;
}

1;
