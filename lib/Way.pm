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

    $self->{way} = shift;
    for my $i (keys %{$self->{way}}) {
        $self->{$i} = $self->{way}->{$i};
    }

    return $self;
}

1;
