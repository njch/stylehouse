package Wormhole;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use File::Slurp;
use JSON::XS;
use Texty;
my $json = JSON::XS->new->allow_nonref(1)->allow_unknown(1);
use HTML::Entities;


has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);
    
    $self->{ghost} = shift;
    my $file = $self->{file} = shift;
    unless (-e $file) {
        say "no $file";
        my ($wom) = $file =~ qr{(wormholes/.+)/};
        unless (-e $wom) {
            mkdir $wom;
        }
        `echo '' > $file`;
    }
    $self->{script} = LoadFile($file);
    say "script: ".Hostinfo::ddump($self->{script});

    return $self;
}
sub ob {
    my $self = shift;
    $self->{ghost}->ob(@_);
}

sub continues {
    my ($self, $ghost) = @_; # %

    my $line = {
        uuid => $self->hostinfo->make_uuid,
        wayin => $ghost->{wayin},
        thing => encode_thing($ghost->{thing}),
        etc => ($ghost->{etc}),
        wayout => $ghost->{wayout},
        depth => $ghost->{depth},
        last => $ghost->{last_state}->{uuid},
        ghost => $ghost,
    };

    $self->ob($line);

    push @{$self->{script}}, $line;

    # travel that $line writing a serialisation in wormhole/$ghostname/
    
    return $line;
}

sub encode_thing {
    my $thing = shift;
    my $out = shift;
    $thing = "~" unless defined $thing;
    return "$thing";
}

# here's a... tube... sticking out the back of this wormhole, Textying the script.
# Form would Ghost all sorts of data type munging and humanisation from lower order geometries
# also space bending etc.
# it can help make a lot of tractograms under the curve of the human show.
# here we call another branch of thought in Ghost Ghost

# this whole procedure should be mapped/plumbed, all the way out to the View, Gods, etc
# and usable as a flowing with nice triggers and invisible but well organised complications.
# it's the call stack/circuit flowing in reverse, from state tube to layers & lingo tricks to items in a Texty.

use YAML::Syck;
sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^     /,
        split "\n", Dump($thing);
}

sub appear {
    my $self = shift;
    my $view = $self->{ghost}->{travel}->{owner};
    ref $view eq "View" || die " $view not View";
    return new Texty($self->hostinfo->intro, $view, $self->{script}, {
        spatialise => sub { { space => 40, top => 50 } },
        tuxts_to_htmls => sub {
            my $self = shift;
            my $newtuxts = [];
            say "Wormhole is ".@{$self->tuxts}." lines long";
            for my $s (@{$self->tuxts}) {
                if ($s->{value} eq "nothing") {
                    push @$newtuxts, $s;
                }
                else {
                    my $ghost = $s->{value}->{ghost};
                    $ghost->hookways("chain_to_tuxts", { texty => $self, s => $s });
                    push @$newtuxts, @{$ghost->{tuxts}};
                }
            }
            $self->tuxts($newtuxts);
        }
    })
}


sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
