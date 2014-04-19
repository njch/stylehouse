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

    $self->{travel} = shift; # joining up to the vastness of the Travels is something
    # one travel = one ghost, to get things going
    # when the ghost becomes more a living datastructure (haha)
    # it will need to be more a shifting tide of Ways 
    # needs a PATHway
    # where LastWormholeID is passed around 

    $self->{wormhole} = new Wormhole($self->hostinfo->intro);
    
    # also something big to join up to
    # it looks like the fuzz of how you want to act while Traveling. yay.
    # which is just the place to join to liquified language
    # there may be more structure through/around a list of lingos we hard code for now
    # it's a tube with no phases yet, just "select ways" and misc chewing
    my $morechains = shift;
    $self->{chains} = Load(<<'YAML');
- ref: HASH
  for: ' [ sort keys %$thing ] '
  travel: ' $thing->{$for} '
  wayd: ' "key $for" '
- for: ' [ @$thing ] '
  ref: ARRAY
  travel: ' $for '
  wayd: ' "[$i]" '
- as: HASH
  note: ' { owner => $thing->view->owner } '
  ref: Texty
- default: " { thing => \"? '$thing' \"}"
  unless: ' ref \$thing eq "SCALAR" '
YAML

    return $self;
}

sub rattle {
    my $self = shift;
    my $depth = shift;
    my $last_state = shift;
    my $in = shift;
    my $thing = shift;

    my $out = [];
    my $def = [];
    my $etc = {};
    for my $c (@{ $self->{chains} }) {
        if ($c->{ref}) {
            if ($c->{ref} eq ref $thing) {
                if ($c->{as}) {
                    push @$out, $self->grep_chains("ref" => $c->{as});
                }
                push @$out, $c;
            }
        }
        if ($c->{default}) {
            push @$def, $c;
        }
    }
    for my $c (@$out) {
        if ($c->{note}) {
            push @{ $etc->{note}||=[] }, doo($c->{note}, $thing);
        }
    }

    if (!@$out) {
        push @$out, @$def;
    }
    return ($out, $etc);
}

sub haunt {
    my $self = shift;
    my $depth = shift;
    my $thing = shift;
    my $in = shift;
    my $last_state = shift;

    my ($out, $etc) = $self->rattle($depth, $last_state, $in, $thing);

    my $state = $self->{wormhole}->continues($in, $self, $last_state, $depth, $thing, $etc, $out); # %

    my $away = [];
    #say "The way out: ".anydump([ $out, "$thing" ]);
    for my $o (@$out) {
        if ($o->{for}) {
            for my $for (@{ doo($o->{for}, $thing) }) {
                if (my $t = $o->{travel}) {
                    push @$away, { travel => { thing => doo($t, $thing, $for), way => { %$o, for => $for } } };
                }
            }
        }
        if (my $d = $o->{default}) {
            if (!$o->{unless} || !doo($o->{unless}, $thing, $d)) {
                push @$away, { travel => { thing => doo($d, $thing), way => $o } };
            }
        }
    }
    #say "Away: ".anydump($away);
    return ($state, $away);
}

sub doo {
    my $eval = shift;
    my $thing = shift;
    my $for = shift;
    my $new;
    my $evs = "\$new = $eval";
    eval $evs;
    if ($@) {
        say "eval - $evs";
        say "Thinf $new";
        die $@;
    }
    return $new;
}

sub grep_chains {
    my $self = shift;
    my %s = @_;
    my @go;
    for my $c (@{ $self->{chains} }) {
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
