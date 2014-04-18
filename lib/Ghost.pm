package Ghost;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;
use Wormhole;


has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{travel} = shift; # joining up to the vastness of the Travels is something

    $self->{wormhole} = new Wormhole($self->hostinfo->intro);
    
    # also something big to join up to
    $self->{chains} = shift || [{
        ref => "HASH",
        for => q{ [ sort keys %$thing ] },
        travel => q{ $thing->{$e} },
    }, {
        ref => "Texty", as => "HASH",
        note => q{ { owner => "not ".$thing->view->owner } },
    }, {
        default => q{ { thing => "? '$thing' "}},
        unless => q{ ref \$thing eq "SCALAR" },
    }];

    return $self;
}

sub haunt {
    my $self = shift;
    my $depth = shift;
    my $thing = shift;
    my $in = shift;

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

    $self->{wormhole}->continues($in, $self, $depth, $thing, $etc, $out); # %

    my $away = [];
    #say "The way out: ".anydump([ $out, "$thing" ]);
    for my $o (@$out) {
        if ($o->{for}) {
            for my $e (@{ doo($o->{for}, $thing) }) {
                if (my $t = $o->{travel}) {
                    push @$away, { travel => { thing => doo($t, $thing, $e), way => { %$o, for => $e } } };
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
    return $away;
}

sub doo {
    my $eval = shift;
    my $thing = shift;
    my $e = shift;
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
