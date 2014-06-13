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

	$self->{wayofthe} = shift;
	$self->{file} = shift;
    $self->load_wayfile();

    return $self;
}
sub load_wayfile {
    my $self = shift;
    my $w = eval { LoadFile($self->{file}) };
    if (!$w || ref $w ne 'HASH' || $@) {
    	die "! YAML load $self->{file} failed: "
        	.($@ ? $@ : "got: ".($w || "~"));
    }
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
