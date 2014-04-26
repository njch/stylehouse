package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use YAML::Syck;

has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{travel} = shift;

    return $self;
}
# }}}


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

sub doo { # here we are in a node, facilitating the popup code that is Way
    my $self = shift;
    my $eval = shift;
    my $ar = shift;
    my $thing = $self->{thing};
    my $download = join "", map { 'my $'.$_.' = $ar->{'.$_."};\n  " } keys %$ar;
    my $upload = join "", map { '$ar->{'.$_.'} = $'.$_.";\n  " } keys %$ar;
    
    my @return;
    my $evs = "$download ".'@return'." = (sub { $eval })->();  $upload";
    eval $evs;
    die Hostinfo::ddump({dooing => [$@, $evs]}) if $@;

    return wantarray ? @return : $return[0]
}

sub haunt { # arrives through here
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
