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
    
    $self->{script} = [];

    return $self;
}

sub continues {
    my ($self, $in, $ghost, $depth, $thing, $etc, $out) = @_; # %
    
    my $line = {
        wayin => ($in),
        thing => encode_thing($thing, $out),
        etc => ($etc),
        wayout => ($out),
        depth => $depth,
    };

    push @{$self->{script}}, $line;
}

sub encode_thing {
    my $thing = shift;
    my $out = shift;
    return "$thing";
}

sub appear {
    my $self = shift;
    my $view = shift;
    return new Texty($self->hostinfo->intro, $view, $self->{script}, {
        spatialise => sub { { space => 80, top => 50 } },
        tuxts_to_htmls => sub {
            my $self = shift;
            my $newtuxts = [];
            say "Here here here".@{$self->tuxts};
            for my $s (@{$self->tuxts}) {
                my $line = $s->{value};
                say anydump($s);
                $s->{left} += $line->{depth} * 40;
                
                my $wins = { %$s };
                $wins->{value} = encode_entities(anydump($line->{wayin}));
                $wins->{style} .= colorf($line->{wayin});
                $wins->{top} -= 10;
                $wins->{style} .= "font-size: 5pt; opacity:0.4;";

                my $wous = { %$s };
                $wous->{value} = encode_entities(anydump($line->{wayout}));
                $wous->{style} .= colorf($line->{wayout});
                $wous->{top} += 10;
                $wous->{style} .= "font-size: 5pt; opacity:0.4;";

                my $etcs = { %$s };
                $etcs->{value} = encode_entities(anydump($line->{etc}));
                $etcs->{value} =~ s/\$x = {};//;
                $etcs->{style} .= colorf($line->{etc});
                $etcs->{style} .= "font-color: #434; font-size: 5pt; opacity:0.4;";
                $etcs->{top} += 20;
                delete $etcs->{left};
                $etcs->{right} = 5;

                my $this = { %$s };
                $this->{value} = encode_entities(anydump($line->{thing}));
                $this->{style} .= "font-color: #bb3564; font-size: 19pt; ".colorf($line->{thing})." opacity:0.4; padding: 0.9em; ";
                $this->{top} -= 30;
                $this->{left} += 50;

                push @$newtuxts, $wins, $wous, $etcs, $this;
            }
            $self->tuxts($newtuxts);
        }
    })
}

sub colorf {
    my $fing = shift;
    my ($color) = $fing =~ /\(0x....(...)/;
    return "" unless $color;
    $color =~ s/[12456789]/a/g;
    return "background-color: #".($color || "fe9").";";
}


sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
