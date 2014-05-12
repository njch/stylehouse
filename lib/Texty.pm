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
    $self->tuxts([]);

    # make a persistent object for this Texty thing
    # dump junk should not be saved
    $self->hostinfo->screenthing($self);

    if (ref $self->lines ne "ARRAY") {
        use Carp;
        confess "f";
    }
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
    my $append;
    if ($hooks) {
        if ($hooks->{append}) {
            $append = delete $hooks->{append};
        }
        $self->hooks->{$_} = $hooks->{$_} for keys %$hooks;
    }
   
    say "Texty Lines: ".anydump($lines) if $self->{debug};
    if ($lines) { 
        $self->lines($lines);
        $self->lines_to_tuxts();
        $self->tuxts_to_htmls();
    }
    return $self->view->takeover($self->htmls, $append);
}
sub spurt { # semi dupe of replace since they do hooks through to takeover...
    my $self = shift;
    my $lines = shift;
    my $hooks = shift;
    $hooks ||= {};
    $hooks->{append} ||= "append";
    return $self->replace($lines, $hooks);
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
    if (scalar(@{ $self->lines }) == 0) {
        say "\n     Texty ".$self->id."   got zero lines\n\n\n\n";
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
            my ($value, $hooks) = @_;

            my $id = ($self->view->id.'-'.$self->id.'-'.$l++); # self->id is Texty-UUIDish from screenthing
            my $tuxt = {
                class => "$class ".$self->view->id,
                id => $id,
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
                if ($value =~ /<span/sgm || $value =~ s/^\!html //s) {
                    $tuxt->{htmlval} = 1;
                    $value =~ s/<<ID>>/$id/g;
                }
                while ($value =~ s/^!(\w+)=(\w+) //s) {
                    $tuxt->{$1} = $2;
                }
            }
            $tuxt->{value} = $tuxt->{htmlval} ? $value : encode_entities($value);
            return $tuxt, @extratuxts;
        };
 
        if (ref \$line eq "SCALAR") {
            say "  Texty Making line a SCALAR: $line" if $self->{debug};
            $line =~ s/\n$//s;
            $line = " " if $line eq "";
            push @tuxts, $mktuxty->($_) for split /\n/, $line;
        }
        else {
            say "  Texty Line is ref: $line" if $self->{debug} && ref $line;
            push @tuxts, $mktuxty->($line);
        }
    }

    $self->tuxts([@tuxts]);

    say "  Texty tuxts made". ddump(\@tuxts) if $self->{debug};

    $self->spatialise();
}

sub spatialise {
    my $self = shift;
    my $geo;
    if ($self->hooks->{spatialise}) {
        $geo = $self->hooks->{spatialise}->();
    }
    my $inc = $geo->{horizontal};
    my $otop = $geo->{top} ||= 20; # TODO use defined-or
    my $oleft = $geo->{left} ||= 30;
    my $ospace = $geo->{space} ||= 20;
    my $i = 0;
    for my $s (@{$self->tuxts}) {
        if ($geo->{horizontal}) {
            $s->{top} = $geo->{top};
            $s->{left} = $geo->{horizontal};
            $geo->{horizontal} += $inc + (length($s->{value}) > 5 ? 11 : 1);
            if ($geo->{wrap_at} && $s->{left} + $geo->{horizontal} > $geo->{wrap_at}) {
                $geo->{horizontal} = 5;
                $geo->{top} += 20;
                next;
            }
            $geo->{horizontal} += 40;
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
        for ("inner") {
            $p->{$_} = delete $mid->{$_} if exists $mid->{$_};
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
