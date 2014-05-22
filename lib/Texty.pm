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
    $self->add_hooks(shift || {});
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

sub add_hooks {
    my $self = shift;
    my $hooks = shift;
    $self->{hooks} ||= {};
    $self->{hooks}->{$_} = $hooks->{$_} for keys %$hooks;
}


sub replace {
    my $self = shift;
    my $L = shift;
    $self->add_hooks(shift);

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
    my $line = shift;
    my $l = shift;
    my $d = shift;

    my $s = {
        class => "$self->{class} ".$self->{id},
        id => $self->{id}.'-'.$l->{l}++,
        style => ($self->{hooks}->{tuxtstyle} || ""),
        value => $line,
    };
    push @{$self->{tuxts}}, $s; # NOT a wormhole!
    if ($d > 0) {
        $s->{id} =~ s/(\d+)$/$d.$1/;
    }

    if (ref $s->{value} eq "Texty") {
        $s->{style} .= "border: 1px solid pink;";
        say "Still do Texty as line\n\n";

                                        push @{$self->{tuxts}}, @{ $s->{value}->{tuxts} }; # NOT a wormhole!
    }
    elsif (ref $s->{value} eq "HASH") {
        if ($s->{value}->{_mktuxt}) {
            $s->{value}->{_mktuxt}->($s->{value}, $s);
        }
        else {
            die "Texty line HASH value confuse: ".ddump($s->{value})
        }
    }
    elsif (ref \$s->{value} eq "SCALAR") {

        while ($s->{value} =~ s/^!(\w+)(?:=(\w+))? //s) {
            $s->{$1} = defined $2 ? $2 : "yep";
        }
        if (!$s->{html} && $s->{value} =~ /<span/sgm) {
            $s->{html} = 1;
            say "$s->{value} is sudden html in $self->{id}\n\n"
        }

        $s->{value} =~ s/<<ID>>/$self->{id}/g;
        if ($s->{value} =~ /\\n/) {
            my $ll = { l => 0 };
            for my $v (split /\\n/, $s->{value}) {
                                        $self->mktuxt($v, $ll, $d+1);
            }
            $s->{value} = "";
        }
    }
}

sub lines_to_tuxts {
    my $self = shift;

    my $L = $self->{lines};
    unless (@$L) {
        push @$L, '!html <h2 style="color: red;text-shadow: 4px 7px 4px #437">¿?</h2>';
    }

    $self->{tuxts} = [];

    my $l = { l => 0 };
    for my $V (@$L) {
        $self->mktuxt($V, $l, 0);
    }

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
            if ($s->{html}) {
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
    if ($s->{html}) {
        if ($v =~ /<h(\d+)>/) {
            my $h = 4 - $1;
            return 15 * $h
        }
        if ($v=~ /<textarea .+? rows="(\d+)"/) {
            return int(((250 / 15) * $1) - $g->{space} + 1);
        }
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
    $id =~ s/(\w+-\w+)-\w+-(\d+)/$1-$2/;
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
        my $p = { %$s };
        while(my ($k,$v) = each %$p) {
            $p->{$k} = ref $v if ref $v;
        }
        my $V = delete($p->{value});
        $V = encode_entities($V) unless $p->{html}; 

        $p->{style} = join "; ", grep /\s/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        
        my $AAA = join " ", map { $_.'="'.$p->{$_}.'"' } sort keys %$p;

        my $span_html = "<span $AAA>$V</span>";
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
    my $event = shift;

    if ($self->{hooks}->{event}) {
        say "Texty $self->{id} hooking event";
        $self->{hooks}->{event}->($self, $event, @_);
    }
    else {
        say "Texty $self->{id} event heading for ".$self->{view}->{id};
        $self->view->event($event, $self);
    }
}



sub owner {
    my $self = shift;
    return $self->view;
}


1;
