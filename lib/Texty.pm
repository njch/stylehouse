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

    $self->view->takeover($self->htmls, $self);

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
    die "L not []" unless ref $L eq "ARRAY";
    $self->add_hooks(shift);

    say "Texty Lines: ".anydump($L) if $self->{debug};

    $self->lines($L || []);
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();

    my $ah = delete $self->{hooks}->{append};
    my @o = $self->view->takeover($self->htmls, $self);
    $self->{hooks}->{append} = $ah if $ah;
    return wantarray ? @o : $o[0]
}

sub editing {
    my $self = shift;

    my @newlines = @{ $self->{output} };
    $self->{output} = [];
    $self->{editing} = 0;

    $self->append([@newlines]);
    say "Texty pushed ".scalar(@newlines)." lines out";
    #say ddump(\@newlines);
}

sub gotline {
    my $self = shift;
    my $line = shift;

    $self->{output} ||= [];
    push @{$self->{output}}, $line;

    return if $self->{editing};

    $self->{hostinfo}->timer(0.2, sub { $self->editing });

    $self->{editing} = 1;
}


sub append { # TRACTOR
    my $self = shift;
    my $lines = shift;
    my $hooks = shift;
    $self->eathooks($hooks) if $hooks;

    $self->{hooks}->{append} = 1;

    my $oldlines = $self->{lines};

    my $total = @$lines + @$oldlines;
    if ($total > 1000) {
        # trip out
    }

    my $oldtuxts = $self->{tuxts};
    my $oldhtmls = $self->{htmls};
    my $oldnospace = $self->{hooks}->{nospace};

    $self->{lines} = $lines;
    $self->{hooks}->{nospace} = 1;

    my $linit = @$oldlines;
    $self->lines_to_tuxts($linit);
    my $tuxts = $self->{tuxts};

    $self->{tuxts} = [ @$oldtuxts, @$tuxts ];
    $self->spatialise() unless $oldnospace;
    $self->{tuxts} = $tuxts;

    $self->tuxts_to_htmls();
    my $htmls = $self->{htmls};

    $self->{lines} = $oldlines;
    $self->{tuxts} = $oldtuxts;
    $self->{htmls} = $oldhtmls;
    push @{$self->{lines}}, @$lines;
    push @{$self->{tuxts}}, @$tuxts;
    push @{$self->{htmls}}, @$htmls;
    delete $self->{hooks}->{nospace};
    $self->{hooks}->{nospace} = $oldnospace if $oldnospace;

    $self->view->takeover($htmls, $self);
}

sub tookover {
    my $self = shift;
    if ($self->{hooks}->{fit_div}) {
        $self->fit_div();
    }
}

sub h_tuxtstyle {
    my $self = shift;
    my $s = shift;

    if (my $ts = $self->{hooks}->{tuxtstyle}) {
        my $style = ref $ts eq "CODE" ? $ts->($s) : $ts;
        if ($style) {
            $s->{style} = $style;
            return;
        }
    }
    $s->{style} = "";
}
sub mktuxt {
    my $self = shift;
    my $line = shift;
    my $l = shift;
    my $d = shift;

    my $s = {
        class => "$self->{class} ".$self->{id},
        id => $self->{id}.'-'.$l->{l}++,
        value => $line,
    };
    $self->h_tuxtstyle($s);
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
            #die "Texty line HASH value confuse: ".ddump($self->{value});
            #say "Something oughtta catch: ". ddump($s->{value});
            #$s->{value} = encode_entities(ddump($s->{value}));
        }
    }
    elsif (ref \$s->{value} eq "SCALAR") {

        while ($s->{value} =~ s/^! (\w+) (?: = ( (?:\w+|'.+?') ) )? \s//sx) {
            if ($1 eq "menu" && !$2) {
                $s->{$1} = undef;
            }
            elsif ($1 eq "style") {
                $s->{style} .= ($2 =~ /^'(.+)'$/)[0];
            }
            else {
                $s->{$1} = defined $2 ? $2 : "yep";
            }
        }
        if (exists $s->{menu} && !defined $s->{menu}) {
            $s->{menu} = $s->{value};
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
    my $linit = shift || 0;

    my $L = $self->{lines};
    unless (@$L) {
        push @$L, '!html <h2 style="color: red;text-shadow: 4px 7px 4px #437">¿?</h2>';
    }

    $self->{tuxts} = [];

    my $l = { l => $linit };
    for my $V (@$L) {
        $self->mktuxt($V, $l, 0);
    }

    if (my $pt = $self->{hooks}->{per_tuxt}) {
        $pt->($_) for @{$self->{tuxts}};
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
    my $otop = $geo->{top} ||= 2; # TODO use defined-or
    my $oleft = $geo->{left} ||= 3;
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
                $geo->{top} += $geo->{space};
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
            return 15 * $h + 10;
        }
        if ($v=~ /<textarea .+? rows="(\d+)"/) {
            return int(((250 / 15) * $1) - $g->{space} + 1);
        }
    }
    return 20;
}

sub fit_div {
    my $self = shift;

    my $max = $self->{max_height};
    my $last = $self->{tuxts}->[-1];
    my ($top) = $last->{top};
    $top += $self->htmlvalue_height($last);
    $top += 10;

    my $scroll_down;
    if ($max && $max < $top) {
        $top = $max;
        $scroll_down = 1;
    }
    $top .= "px";

    my $divid = $self->{view}->{divid};
    $self->{hostinfo}->send(qq{  \$('#$divid').css('height', '$top')  });
    if ($scroll_down) {
        $self->{hostinfo}->send(qq{ \$('#$divid').scrollTop($last->{top});  });
    }
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

    my $t = [ @{ $self->tuxts } ];

    if ($self->{hooks}->{append} && @$t> 666 / 8) {
        $t = [ splice @$t, -666/8 ];
    }

    my @htmls;
    for my $s (@$t) {
        if ($self->{hooks}->{tuxts_to_htmls_tuxt}) {
            $self->{hooks}->{tuxts_to_htmls_tuxt}->($self, $s);
        }

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
    
    my $evh = $self->{hooks}->{event};
    if (ref $evh eq "CODE") {
        say "Texty $self->{id} $self->{view}->{divid} hooking event->()";
        $evh->($self, $event, @_);
    }
    elsif (ref $evh eq "HASH") {
        my $menu = $evh->{menu};
        my $s = $self->id_to_tuxt($event->{id});
        if (my $m = $s->{menu}) {
            $menu->{$m}->($event, $s);
        }
        else {
            $self->{hostinfo}->error("unhandled tuxt click", $event, $s);
        }
    }
    else {
        say "Event id: ".$event->{id};
        say "Texty $self->{id} $self->{view}->{divid} event heading for ".$self->{view}->{id};
        $self->view->event($event, $self);
    }
}



sub owner {
    my $self = shift;
    return $self->view;
}


1;
