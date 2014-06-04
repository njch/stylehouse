package Way;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Texty;

has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->downway(shift);

    return $self;
}

sub downway {
    my $self = shift;
    $self->{file} = shift;
    my $w = LoadFile($self->{file});
    # merge the ways into $self
    for my $i (keys %$w) {
        $self->{$i} = $w->{$i};
    }
    if ($self->{chains}) {
        for my $c (@{$self->{chains}}) {
            $c->{way} ||= $self;
        }
    }
}

1;
