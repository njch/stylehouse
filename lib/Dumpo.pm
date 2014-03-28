package Dumpo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;

    my $view = "hodu";

    $self->hostinfo(shift->hostinfo);
    if ($self->hostinfo->get('Dumpo')) {
        $self->hostinfo->tx->send("\$('#$view span').remove();");
    }
    $self->hostinfo->set('Dumpo', $self);

    my $dump = $self->hostinfo->dump("dontsay");
    my $text = new Texty($self, [grep { !/^       / } split("\n", $dump)], { view => $view, skip_hostinfo => 1 });
    return $self;
}

1;
