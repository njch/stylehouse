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
    my ($self, $ghost) = @_; # %

    my $line = {
        uuid => $self->hostinfo->make_uuid,
        wayin => $ghost->{wayin},
        thing => encode_thing($ghost->{thing}),
        etc => ($ghost->{etc}),
        wayout => $ghost->{wayout},
        depth => $ghost->{depth},
        last => $ghost->{last_state}->{uuid},
    };

    push @{$self->{script}}, $line;
    
    return $line;
}

sub encode_thing {
    my $thing = shift;
    my $out = shift;
    $thing = "~" unless defined $thing;
    return "$thing";
}

# here's another Wormhole sticking out the back of this one, Textying into human forms.
# by starting a texty first,
# catching up with things in the middle,
# using our Ghost, who should know what it's doing here...

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
    my $view = shift;
    return new Texty($self->hostinfo->intro, $view, $self->{script}, {
        spatialise => sub { { space => 40, top => 50 } },
        tuxts_to_htmls => sub {
            my $self = shift;
            my $newtuxts = [];
            say "Wormhole is ".@{$self->tuxts}." lines long";
            for my $s (@{$self->tuxts}) {
                my $line = $s->{value};
                $s->{left} += $line->{depth} * 40;
                
                my $wins = { %$s };
                $wins->{id} .= "-wins";
                my $wi = $line->{wayin};
                $wins->{value} = "(nowhere)";
                $wins->{value} = encode_entities(getway($wi)) if $wi;
                $wins->{style} .= colorf(!$wi ? $wi : $wi->{way});
                $wins->{top} -= 10;
                $wins->{style} .= "font-size: 5pt; opacity:0.4;";

                my $wous = { %$s };
                $wous->{id} .= "-wous";
                my $wo = $line->{wayout};
                do {
                    my $sum = scalar(@$wo)." ways";
                    say $sum;
                    $wo = $wo->[0];
                    say ddump({aboutto=>$wo});
                    my $eg = encode_entities(getway($wo)) if $wo;
                    $eg ||= "(no futher)";
                    $wous->{value} = "$sum $eg";
                    $wous->{style} .= colorf($wo);
                    $wous->{top} += 10;
                    $wous->{style} .= "font-size: 5pt; opacity:0.4;";
                };

                my $etcs = { %$s };
                $etcs->{id} .= "-etcs";
                $etcs->{value} = encode_entities(anydump($line->{etc}));
                $etcs->{value} =~ s/\$x = {};//;
                $etcs->{style} .= colorf($line->{etc});
                $etcs->{style} .= "font-color: #434; font-size: 5pt; opacity:0.4;";
                $etcs->{top} += 20;
                delete $etcs->{left};
                $etcs->{right} = 5;

                my $this = { %$s };
                $this->{id} .= "-this";
                $this->{value} = encode_entities($line->{thing});
                $this->{style} .= "font-color: #bb3564; font-size: 15pt; ".colorf($line->{thing})." opacity:0.4; padding: 0.9em; ";
                $this->{style} .= "border: 2px dotted red;" if ref $line->{thing};
                $this->{top} -= 30;
                $this->{left} += 50;

                push @$newtuxts, grep { $_->{value} =~ s/\n/<br>/; 1 } $this, $etcs, $wins, $wous;
            }
            $self->tuxts($newtuxts);
        }
    })
}

sub getway {
    my $way = shift;
    join "\n", map { "$_: $way->{$_}" } keys %$way
}

sub colorf {
    my $fing = shift;
    my ($color) = ($fing || "0") =~ /\(0x....(...)/;
    return "border: 1px solid black;" unless $color;
    $color ||= "fff";
    
    $color =~ s/([12457])/$1.($1+2)/eg;
    return "background-color: #".($color || "fe9").";";
}


sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
