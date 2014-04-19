package Way;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;


has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    return $self;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
