package Wormhole;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;


has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);
    
    $self->{script} = [];

    return $self;
}

sub continues {
    my ($self, $in, $ghost, $depth, $thing, $etc, $out) = @_; # %
    
    my @lines = (
        "wayin: ".json_encode($move),
        "thing: ".thing_encode($thing),
        "etc: ".json_encode($etc),
        "wayout: ".json_encode($in),
    );

    ref $_ || s/^/('  ')x$depth/e for @lines;

    push @{$self->{script}}, join "\n", @lines;
}

sub thing_encode {
    my $self = shift;
    my $thing = shift;
    return "$thing";
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
