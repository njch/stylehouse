package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;
use Texty;
use Wormhole;

has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{travel} = shift;

    $self->hostinfo->load_ghost($self); # ways & wormhole

    
    # Way also something big to join up to
    # it looks like the fuzz of how you want to act while Traveling. yay.
    # which is just the place to join to liquified language
    # there may be more structure through/around a list of lingos we hard code for now
    # it's a tube with no phases yet, just "select ways" and misc chewing

    # we eat all the ways and fire their hooks through our flow
    # so expression can be ordered more by theme, not scattered over variation
    # anyway this gets stored somehow and edited in codemirror, via Codo?

    for my $w (@{$self->{ways}}) {
        for my $c (@{$w->{chains}}) {
            $c->{way} ||= $w;
        }
    }

    return $self;
}
# }}}

sub load_way {
    my $self = shift;
    my $this = shift;
    my $name = ref $this;
    $self->{ways} = []; # should be hostinfoways replacement maneuvre
    push @{$self->{ways}}, map { new Way($self->hostinfo->intro, LoadFile("ghosts/$name/$_")) } glob "ghosts/$name/*";
}

sub colorf {
    my $fing = shift;
    my ($color) = ($fing || "0") =~ /\(0x....(...)/;
    return "border: 1px solid black;" unless $color;
    $color ||= "fff";
    return "background-color: #".($color || "fe9").";";
}
sub chains {
    my $self = shift;
    map { @{ $_->{chains} } } @{ $self->{ways} }
}

sub hookways {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    my $wayspec = shift;
    # these might want to be ordered
    # so things can gather at points of the program workflow like "maketravels"
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    for my $w (@{ $self->{ways} }) {
        next if $wayspec && $w ne $wayspec;
        if (exists $w->{hooks}->{$point}) {
            $self->doo($w->{hooks}->{$point}, $ar);
        }
    }
}

sub doo {
    my $self = shift;
    my $eval = shift;
    my $ar = shift;
    my $thing = $self->{thing};
    my $download = map { 'my $'.$_.' = $ar->{'.$_."};\n  " } keys %$ar;
    my $upload = map { '$ar->{'.$_.'} = $'.$_.";\n  " } keys %$ar;
    
    my $for = $ar->{for};
    my $c = $ar->{c};

    my @return;
    my $evs = "$download \@return = (sub { $eval })->();  $upload";
    eval $evs;
    die anydump({dooing => [$@, $eval]}) if $@;

    return wantarray ? @return : $return[0]
}

sub haunt {
    my $self = shift;
    $self->{depth} = shift;
    $self->{thing} = shift;
    $self->{wayin} = shift;
    $self->{last_state} = shift;

    $self->{wayout} = [];
    $self->hookways("donetravels");
    $self->{away} = []; # of {} args to Travel
    $self->hookways("donethinking");

    my $state = $self->{wormhole}->continues($self); # %

    $self->hookways("maketravels");
    return ($state, $self->{away});
}

sub grep_chains {
    my $self = shift;
    my %s = @_;
    my @go;
    for my $c ($self->chains) {
        while (my ($k, $v) = each %s) {
            if ((!$k || exists $c->{$k}) && (!$v || $c->{$k} =~ $v)) {
                push @go, $c;
            }
        }
    }
    return @go;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
