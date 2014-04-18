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
        "wayin: ".encode_json($in),
        "thing: ".encode_thing($thing, $out),
        "etc: ".encode_json($etc),
        "wayout: ".encode_json($out),
    );

    ref $_ || s/^/('  ')x$depth/e for @lines;

    push @{$self->{script}}, join "\n", @lines;
}

sub encode_thing {
    my $self = shift;
    my $thing = shift;
    my $out = shift;
    return "$thing";
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
