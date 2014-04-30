package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{owner} = shift; # id instead of link, is wrong at the next level
    $self->{name} = $self->{owner}->id;
    unless (ref $self->{owner} eq "Travel") {
        # observer of whole codon function
        $self->{self} = new Travel($self->hostinfo->intro, $self);
    }
    else {
        # all travels of travels
        push @{ $self->hostinfo->get('Travel Travel') }, $self;
    }

    return $self;
}

sub ob {
    my $self = shift;
    my @seen = @_;

    # good place to way up with strings/tubes
    my $stack = [ map { "$_->[0] $_->[3] ($_->[1] $_->[2])" } map { [ caller($_) ] } 0..10 ];
    
    my $data = Hostinfo::ddump(\@seen);

    my $ob = [ $stack, $data ];

    $self->{self}->travel($ob);

    push @{$self->hostinfo->get("Codo/obsetrav")}, $ob;
}

# what's a wormhole of ghosts? hookways mixes ways
sub travel {
    my $self = shift;
    my $thing = shift;
    my $ghost = shift || new Ghost($self->hostinfo->intro, $self);
    say "The Ghost: ".Hostinfo::ddump($ghost);
    my $way = shift;
    my $depth = shift || 0;
    my $last_state = shift;

    if (!$depth) {
        $self->hostinfo->getapp("Codo")->take_picture("travel!", $thing);
    }

    my ($state, $away) = $ghost->haunt($depth, $thing, $way, $last_state);

    if (!@$away) {
        return "";
    }

    for my $c (@$away) {
        if (my $t = $c->{travel}) {
            $self->travel($t->{thing}, $ghost, $t->{way}, $depth+1, $state);
        }
    }

    return $ghost->{wormhole};
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
