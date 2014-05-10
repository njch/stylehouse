package Menu;
use base 'Base';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{view} = shift;
    
    # pick apart spec for us & our texty
    $self->{hooks} = shift;

    $self->{text} = new Texty($self->hi->intro, $self->{view}, [], $self->{hooks});

    return $self;
}

sub replace {
    my $self = shift;

    my $items = $self->{items} = shift;

    say "Writing Menu  ".$self->{view}->{id}."    ".join ", ", map { ref $_ eq "Codon" ? $_->{name} : ref $_ } @$items;

    $self->text->replace([@$items]);

    return $self;
}

sub event {
    my $self = shift;
    my $event = shift;
    my $height = $self->hi->get("screen/height");
    $height ||= 900;
    my $h = {};

    # get this event to go to the right object
    my $id = $event->{id};

    my ($origin, $method) = $self->route_menu_id($id);
    
    if ($origin) {
        my $menu = $origin->menu();
        $method = decode_entities($method);
        unless ($menu->{$method}) {
            die "Menu for $origin has no $method";
        }
        $menu->{$method}->($event);
    }
    else {
        say "Nope wrong: ";
        $self->hi->flood($self->text);
    }
}

sub route_menu_id {
    my $self = shift;
    my $id = shift;
    my $texty = $self->{text};

    my $ids = {};
    for my $tuxt (@{ $texty->tuxts }) {
        $ids->{$tuxt->{id}} = [$tuxt->{origin}, "."];
        for my $subtuxt (@{ $tuxt->{inner}->tuxts }) {
            $ids->{$subtuxt->{id}} = [$tuxt->{origin}, $subtuxt->{value}];
        }
    }

    unless ($ids->{$id}) {
        die "no $id!".ddump($ids);
    }
    return @{$ids->{$id}}
}

1;
