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

    $self->view(shift || die "need owner");
    $self->lines(shift || []);
    $self->hooks(shift || {});
    $self->{class} = $self->{hooks}->{class} || "data";
    $self->tuxts([]);

    if (ref $self->lines ne "ARRAY") {
        use Carp;
        confess "f";
    }
    return $self if ! @{ $self->lines };

    die "never" if ref $self->view eq "HAsH";

    $self->lines_to_tuxts();

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
    my $L = shift;
    my $hooks = shift;
    if ($hooks) {
        $self->{hooks}->{$_} = $hooks->{$_} for keys %$hooks;
    }

    say "Texty Lines: ".anydump($L) if $self->{debug};

    $self->lines($L || []);
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();

    return $self->view->takeover($self->htmls, $self);
}
sub spurt { # semi dupe of replace since they do hooks through to takeover...
    # supposed to add a few more lines, percolate them through to the screen with minimal effort
    my $self = shift;
    my $lines = shift;
    my $hooks = shift;
    $hooks ||= {};
    $hooks->{append} ||= "append";
    return $self->replace($lines, $hooks);
}

sub append { # TRACTOR
    my $self = shift;
    my $new = shift;
    push @{ $self->lines }, @$new;
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();
    my @newhtml;
    my @allhtml = @{$self->htmls};
    for (1..scalar(@$new)) {
        push @newhtml, pop @allhtml;
    }
    $self->view->takeover([@newhtml], "append");
}

sub mktuxt {
    my $self = shift;
    my $V = shift;
    my $l = shift;
    my $d = shift;

    my $s = {
        class => "$self->{class} ".$self->{id},
        id => $self->{id}.'-'.$l->{l}++,
        style => ($self->{hooks}->{tuxtstyle} || ""),
    };
    if ($d > 0) {
        $s->{id} =~ s/(\d+)$/$d.$1/;
    }

    my @moire; # forms interrupting forms

    if (ref $V eq "Texty") {
        $s->{style} .= "border: 1px solid pink;";

                                        push @moire, @{ $V->{tuxts} }; # NOT a wormhole!
    }
    elsif (ref $V eq "HAsH") {
        if ($V->{_mktuxt}) {
            $V->{_mktuxt}->($V, $s);
        }
        else {
            die "Texty line HAsH value confuse: ".ddump($V)
        }
    }
    elsif (ref \$V eq "sCALAR") {

        while ($V =~ s/^!(\w+)(?:=(\w+))? //s) {
            $s->{$1} = defined $2 ? $2 : "yep";
        }
        if (!$s->{html} && $V =~ /<span/sgm) {
            $s->{html} = 1;
            say "$V is sudden html in $self->{id}\n\n"
        }

        $V =~ s/<<ID>>/$self->{id}/g;
        if ($V =~ /\\n/) {
            my $ll = { l => 0 };
            for my $v (split /\\n/, $V) {

                                        push @moire, $self->mktuxt($v, $ll, $d+1);
            }
        }
    }

    $s->{value} = $s->{html} ? $V: encode_entities($V);

    return $s, @moire
}

sub lines_to_tuxts {
    my $self = shift;

    my $L = $self->{lines};
    unless (@$L) {
        push @$L, '!html <h2 style="color: red;text-shadow: 4px 7px 4px #437">¿?</h2>';
    }

    my $l = { l => 0 };
    $self->tuxts([
        map {
            $self->mktuxt($_, $l, 0);
        } @$L
    ]);

    $self->spatialise() unless $self->{hooks}->{nospace};
}

sub spatialise {
    my $self = shift;
    my $geo;
    if ($self->hooks->{spatialise}) {
        $geo = $self->hooks->{spatialise}->();
    }
    my $inc = $geo->{horizontal} if $geo->{horizontal};
    my $otop = $geo->{top} ||= 20; # TODO use defined-or
    my $oleft = $geo->{left} ||= 30;
    $geo->{horizontal} = $oleft if $geo->{horizontal};
    my $ospace = $geo->{space} ||= 20;
    my $i = 0;
    for my $s (@{$self->tuxts}) {
        if ($geo->{horizontal}) {
            $s->{top} = $geo->{top};
            $s->{left} = $geo->{horizontal};
            my $guessextrawidth = sub { # wants to be a Tractor
                return 20 unless ref $s->{value} eq "HAsH";
                # TODO link back to the line before tuxtying
                # would be handy as to string the facets together prog-y-y and also in phsyical display space to create chains of parts of things...
                return 11*6 if length($s->{value}->{name}) > 7;
                return 1;
            };
            $geo->{horizontal} += $inc + $guessextrawidth->();
            if ($geo->{wrap_at}   &&   $s->{left} + $geo->{horizontal} > $geo->{wrap_at}) {
                $geo->{horizontal} = $oleft;
                $geo->{top} += 20;
                next;
            }
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
            if ($s->{htmlval}) {
                $geo->{top} += $self->htmlvalue_height($s, $geo);
            }
        }
        $i++;
    }
}

sub htmlvalue_height {
    my $self = shift;
    my $s = shift;
    my $g = shift;
    my $v = $s->{value};
    if ($v =~ /<h(\d+)>/) {
        my $h = 4 - $1;
        return 15 * $h
    }
    if ($v=~ /<textarea .+? rows="(\d+)"/) {
        return int(((250 / 15) * $1) - $g->{space} + 1);
    }
    return 20;
}

sub fit_div {
    my $self = shift;
    my $last = $self->{tuxts}->[-1];
    my ($top) = $last->{top};
    $top += $self->htmlvalue_height($last);
    if ($self->{max_height}) {
        if ($self->{max_height} < $top) {
            $top = $self->{max_height};
        }
    }
    $top .= "px";

    my $divid = $self->{view}->{divid};
    $self->{hostinfo}->send(qq{  \$('#$divid').css('height', '$top')  });
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
    
    my $from = join ", ", (caller(1))[0,3,2];
    #say "tuxts_to_htmls from: $from";

    if ($self->{hooks}->{tuxts_to_htmls}) {
        $self->{hooks}->{tuxts_to_htmls}->($self);
    }

    my $top_add = 0;
    my @htmls;
    for my $s (@{$self->tuxts}) {
        my $p = { %$s };
        delete $p->{origin};
        delete $p->{inner};
        my $value = delete($p->{value});

        $p->{style} = join "; ", grep /\s/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;

        my $span_html = "<span $attrstring>$value</span>";
        push @htmls, $span_html;
        
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

    say "Event in $self->{id} heading for ".$self->{view};

    $self->view->event($tx, $event, $self);
}

sub owner {
    my $self = shift;
    return $self->view;
}


1;
