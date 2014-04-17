package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;


has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{travel} = shift; # joining up to the vastness of the Travels is something

    $self->{wormhole} = new Wormhole($self->hostinfo->intro);

    return $self;
}

sub haunt {
    my $self = shift;
    #my $where = shift; # where is in us, we are now next thing long
    my $thing = shift;
    my $in = shift; # all board games are haunted as

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
        if ($c->{note}) {
            push @{ $etc->{note}||=[] }, $c->{note}->($thing);
        }
    }

    if (!@$out) {
        @$out = @$def;
    }

    $self->{wormhole}->continues($in, $self, $depth, $thing, $etc, $out); # %

    my $away = [];
    for my $o (@$out) {
        if ($o->{for}) {
            for my $e ($o->{for}->($thing)) {
                if (my $t = $o->{travel}) {
                    push @$away, { travel => { thing => $t->($thing, $e), way => { %$o, for => $e } } };
                }
            }
        }
        if (my $d = $o->{default}) {
            push @$away, { travel => [ $d->($thing), $o ] };
        }
    }
    return $away;
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
    return \@go;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
