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

    $self->{wormhole} = new Wormhole($self->hostinfo->intro);
    
    # Way also something big to join up to
    # it looks like the fuzz of how you want to act while Traveling. yay.
    # which is just the place to join to liquified language
    # there may be more structure through/around a list of lingos we hard code for now
    # it's a tube with no phases yet, just "select ways" and misc chewing

    # we eat all the ways and fire their hooks through our flow
    # so expression can be ordered more by theme, not scattered over variation
    push @{ $self->{ways} ||= [] },
        map { new Way($self->hostinfo->intro, Load($_)) } <<'YAML',
name: ghost
hooks:
  donetravels: |
    for my $c ($self->chains) {
        $self->hookways("donetravels_chain", {c => $c});
    }
  maketravels: |
    for my $c (@{$self->{wayout}}) {
        $self->hookways("maketravels_chain", {c => $c});
    }
    if (!@{$self->{away}}) {
        for my $dc (grep { $_->{default} } $self->chains) {
            if (!$dc->{unless} || !$self->doo($dc->{unless})) {
                push @{$self->{away}}, { travel => { thing => $self->doo($dc->{default}), way => { %$dc } } };
            }
        }
    }
YAML
<<'YAML',
hooks:
  donetravels_chain: |
    if ($c->{ref}) {
        if ($c->{ref} eq ref $thing) {
            if ($c->{as}) {
                push @{$self->{wayout}}, $self->grep_chains("ref" => $c->{as});
            }
            push @{$self->{wayout}}, $c;
        }
    }
  maketravels_chain: |
    if ($c->{for}) {
        my $i = 0;
        for my $for (@{ $self->doo($c->{for}) }) {
            if (my $t = $c->{travel}) {
                push @{$self->{away}}, {
                    travel => {
                        thing => $self->doo($t, {for => $for}),
                        way => { %$c, i => $i++, value => $for }
                    }
                };
            }
        }
    }
chains:
 - ref: HASH
   for: ' [ sort keys %$thing ] '
   travel: ' $thing->{$for} '
 - ref: ARRAY
   for: ' [ @$thing ] '
   travel: ' $for '
 - as: HASH
   note: ' { owner => $thing->view->owner } '
   ref: Texty
YAML
<<'YAML',
name: notes
hooks:
  donethinking: |
    for my $c (@{$self->{out}}) {
        if ($c->{note}) {
            push @{ $self->{etc}->{note}||=[] }, $self->doo($c->{note});
        }
    }
YAML
<<'YAML',
chains:
 - default: " \"? '$thing' \""
   unless: ' ref \$thing eq "SCALAR" '
YAML
    ;

    for my $w (@{$self->{ways}}) {
        for my $c (@{$w->{chains}}) {
            $c->{way} ||= $w;
        }
    }

    return $self;
}

sub chains {
    my $self = shift;
    map { @{ $_->{chains} } } @{ $self->{ways} }
}

sub hookways {
    my $self = shift;
    my $point = shift;
    my $ar = shift;
    # these might want to be ordered
    # so things can gather at points of the program workflow like "maketravels"
    # and be the big thing to do or a little thing to do
    # these stuff go together like that, hopefully, with language forming their surface tension
    for my $w (@{ $self->{ways} }) {
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
    my $for = $ar->{for};
    my $c = $ar->{c};

    my $do;
    my $evs = "\$do= sub { $eval }";
    eval $evs;
    die anydump({dooing => [$@, $eval]}) if $@;

    return $do->();
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
