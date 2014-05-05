package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use HTML::Entities;
use Storable 'dclone';
use JSON::XS;
my $json = JSON::XS->new->allow_nonref(1);

has 'hostinfo';
has 'view';
has 'lines';
has 'hooks' => sub { {} };

has 'id';
has 'tuxts';
has 'htmls';

has 'empty';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $notakeoveryet = $_[0] && $_[0] eq "..." && shift @_;
    say "@_";

    $self->view(shift || die "need owner");
    $self->lines(shift || []);
    $self->hooks(shift || {});
    $self->tuxts([]);

    # make a persistent object for this Texty thing
    # dump junk should not be saved
    $self->hostinfo->screenthing($self);

    return $self if ! @{ $self->lines };

    $self->lines_to_tuxts() eq "bail" && return;

    $self->tuxts_to_htmls();
    
    # make leaving here default?
    # the rest could be attracted to View
    # attention shoving should be something that reaches here and figures out whether to...
    return $self if $self->hooks->{notakeover} || $notakeoveryet;

    $self->view->takeover($self->htmls);

    return $self;
}

sub replace {
    my $self = shift;
    my $lines = shift;
    my $hooks = shift;
    if ($hooks) {
        $self->hooks->{$_} = $hooks->{$_} for keys %$hooks;
    }
   
    if ($lines) { 
        $self->lines($lines);
        $self->spatialise();
        $self->lines_to_tuxts();
        $self->tuxts_to_htmls();
    }
    $self->view->takeover($self->htmls);
}
sub spurt {
    my $self = shift;
    my $lines = shift;
    my $hooks = shift;
    if ($hooks) {
        $self->hooks->{$_} = $hooks->{$_} for keys %$hooks;
    }
    $self->lines($lines);
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();
    $self->view->takeover($self->htmls, "append");
}

sub append {
    my $self = shift;
    my @new = @_;
    push @{ $self->lines }, @new;
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();
    my @newhtml;
    my @allhtml = @{$self->htmls};
    for (1..scalar(@new)) {
        push @newhtml, pop @allhtml;
    }
    if ($self->empty) {
        $self->empty(0);
        $self->view->takeover([@newhtml]);
    }
    else {
        $self->view->takeover([@newhtml], "append");
    }
}

sub lines_to_tuxts {
    my $self = shift;

    # bizzare
    if (!@{ $self->lines }) {
        say "\nThat thing happened to ".$self->id."\n\n\n\n";
        $self->tuxts([]);
    }

    if (ref $self->view eq "HASH") {
        say "Here's something: ". join ", ", keys %{ $self->view };
        my $delay = Mojo::IOLoop::Delay->new();
        $delay->steps(
            sub { Mojo::IOLoop->timer(1 => $delay->begin); },
            sub { $self->lines_to_tuxts(); },
        );
        return "bail";
    }

    my $l = 0;
    my @tuxts;
    for my $line (@{ $self->lines }) {
        my $class = $self->hooks->{class} || "data";

        my $mktuxty;
        $mktuxty = sub {
            my $value = shift;
            my $hooks = shift;
            my $tuxt = {
                class => "$class ".$self->view->id,
                id => ($self->view->id.'-'.$self->id.'-'.$l++),
                style => "",
            };
            my @extratuxts;

            if ($hooks->{inner_linebreak}) {
                $tuxt->{style} .= "border-left: 3px solid blue;";
            }
            if ($value =~ /;\\n/) {
                say "\nGoing to split probable perl code: '$value'\n";
                return map { $mktuxty->("$_", {inner_linebreak=>1}) } split /\\n/, $value;
            }

            if (ref $value eq "Texty") {
                $tuxt->{style} .= "border: 1px solid pink;";
                my @inners = @{ $value->tuxts }; # NOT a wormhole!
                $_->{left} += 20 for @inners;
                push @extratuxts, @inners;
            }
            else {
                $value = encode_entities($value)
                    unless $value =~ /<span|<textarea/sgm;
            }
            $tuxt->{value} = $value;
            return $tuxt, @extratuxts;
        };
 
        if (ref \$line eq "SCALAR") {
            $line =~ s/\n$//s;
            push @tuxts, $mktuxty->($_) for split /\n/, $line;
        }
        else {
            push @tuxts, $mktuxty->($line);
        }
    }

    $self->tuxts([@tuxts]);

    $self->spatialise();
}

sub spatialise {
    my $self = shift;
    my $geo;
    if ($self->hooks->{spatialise}) {
        $geo = $self->hooks->{spatialise}->();
    }
    $geo->{top} ||= 20;
    $geo->{left} ||= 30;
    $geo->{space} ||= 20;
    my $i = 0;
    for my $s (@{$self->tuxts}) {
        if ($geo->{horizontal}) {
            $s->{top} = 0;
            $s->{left} = $i * $geo->{horizontal};

        }
        else {
            $s->{top} = $geo->{top};
            if ($s->{right}) {
                $s->{right} ||= 0;
                $s->{right} += $geo->{right};
            }
            else {
                $s->{left} ||= 0;
                $s->{left} += $geo->{left} if $geo->{left};
            }
            $geo->{top} += $geo->{space};
        }
        $i++;
    }
}
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub id_to_tuxt {
    my $self = shift;
    my $id = shift;
    for my $s (@{$self->tuxts}) {
        return $s if $s->{id} eq $id;
    }
    return undef;
}

sub tuxts_to_htmls {
    my $self = shift;
    if ($self->{hooks}->{tuxts_to_htmls}) {
        $self->{hooks}->{tuxts_to_htmls}->($self);
    }

    my $top_add = 0;
    my @htmls;
    for my $s (@{$self->tuxts}) {
        my $mid = { %$s };
        delete $mid->{origin};
        my $value = delete($mid->{value});
        my $p = {};
        if (exists $mid->{inner}) {
            $p->{inner} = delete $mid->{inner};
        }
        my $pm = dclone $mid;
        $p = { %$pm, %$p };

        $p->{style} = join "; ", grep /\S/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;

        my $span_html = "<span $attrstring>$value</span>";
        push @htmls, $span_html;
        
    }

    if ($self->{hooks}->{div}) {
        unshift @htmls, '<div id="'.$self->view->id.'-'.$self->{hooks}->{div}.'">';
        push @htmls, '</div>';
    }
    $self->htmls([@htmls]);
}
use YAML::Syck;
sub ddump {
    my $thing = shift;
    return join "\n",
        grep !/^     /,
        split "\n", Dump($thing);
}


sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;

    $self->view->event($tx, $event, $self);
}

sub owner {
    my $self = shift;
    return $self->view;
}


1;
