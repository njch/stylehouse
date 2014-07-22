package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use HTML::Entities;
use Storable 'dclone';
use JSON::XS;
sub ddump { Hostinfo::ddump(@_) }
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

    $self->view(shift);
    $self->lines(shift || []);
    $self->add_hooks(shift || {});
    $self->{class} ||= "data";
    $self->tuxts([]);

    if (ref $self->lines ne "ARRAY") {
        use Carp;
        confess "f";
    }
    return $self if ! @{ $self->lines };

    $self->lines_to_tuxts();

    $self->tuxts_to_htmls();
    
    # make leaving here default?
    # the rest could be attracted to View
    # attention shoving should be something that reaches here and figures out whether to...
    return $self if !$self->{view} || $self->hooks->{notakeover} || $notakeoveryet;

    $self->view->takeover($self->htmls, $self);

    return $self;
}
sub spawn {
    my $self = shift;
    my $L = shift;
    my $H = shift;
    new Texty($self->{hostinfo}->intro, undef, $L, $H);
}
sub add_hooks {
    my $self = shift;
    my $hooks = shift;
    my $h = $self->{hooks} ||= {};
    $h->{$_} = $hooks->{$_} for keys %$hooks;
    if (my $c = $h->{class}) {
        $self->{class} = $c;
    }
    if ($h->{event} && ref $h->{event} eq "HASH") {
        if (my $m = $h->{event}->{menu}) {
            if (ref $m eq "ARRAY") {
                my @m = @$m;
                my $gm = { @m };
                my $mh = {};
                for my $k (keys %$gm) {
                    my $kk = $k;
                    $kk =~ s/^!style='.+?' //;
                    $mh->{$kk} = $gm->{$k};
                }
                $h->{event}->{menu} = $mh;
                say "Keys:".join" ", keys %$mh;
                my $newl = [];
                while (my $k = shift @$m) {
                    push @$newl, $k;
                    shift $m;
                }
                unshift @{$self->{lines}}, @$newl;
            }
        }
    }
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

    if (my $style = $self->{hooks}->{tuxtstyle}) {
        if (ref $style eq "CODE") {
            $style->($s->{value}, $s);
        }
        else {
            $s->{style} = $style;
        }
    }
    else {
        $s->{style} = "";
    }
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
    push @{$self->{tuxts}}, $s;
    
    $self->h_tuxtstyle($s);
    $line = $s->{value};
    
    
    if ($d > 0) {
        $s->{id} =~ s/(\d+)$/$d.$1/;
    }

    if (ref $line eq "Texty") {
        # yes...
    }
    elsif (ref $line eq "HASH") {
        if ($line->{_mktuxt}) {
            $line->{_mktuxt}->($line, $s);
        }
        elsif (my $LH = $line->{_spawn}) {
            if (my $ct = $line->{S_attr}) {
                for my $k (keys %$ct) {
                $s->{$k} = $k =~ /class|style/ ?
                    "$s->{$k} $ct->{$k}"
                    :
                    $ct->{k};
                }
            }
            $line = $self->spawn(@$LH);
        }
        else {
            #
        }
    }
    elsif (ref \$line eq "SCALAR") {

        while ($line =~ s/^! (\w+) (?: = ( (?:\w+|'.+?') ) )? \s//sx) {
            if ($1 eq "menu" && !$2) {
                $s->{$1} = undef;
            }
            elsif ($1 eq "style") {
                $s->{style} .= ($2 =~ /^'(.+)'$/)[0];
            }
            elsif ($1 eq "class") {
                $s->{class} .= " $2";
            }
            else {
                $s->{$1} = defined $2 ? $2 : "yep";
            }
        }
        if (exists $s->{menu} && !defined $s->{menu}
            || $self->{hooks}->{all_menu}) {
            $s->{menu} = $line;
        }

        $line =~ s/<<ID>>/$self->{id}/g;
        if ($line =~ /\\n/) {
            my $ll = { l => 0 };
            for my $v (split /\\n/, $line) {

                                        $self->mktuxt($v, $ll, $d+1);
            }
            $line = "";
        }
    }
    $s->{value} = $line;
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
            $p->{$k} = ref $v if ref $v && $k ne 'value';
        }
        my $V = delete $p->{value};
        delete $p->{$_} for grep { /^_/ } keys %$p;
        
        if (ref $V eq "Texty") {
        #if (!$V->{htmls}) { delete $V->{hostinfo}; say "Thing inside ".ddump($V) }
            $V = join "", @{ $V->{htmls} || [] };
        }
        elsif (!$p->{html}) {
            $V = encode_entities($V);
        }

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
sub event {
    my $self = shift;
    my $event = shift;
    
    my $evh = $self->{hooks}->{event};
    my $s = $self->id_to_tuxt($event->{id});
    if ($s->{_event}) {
        say "hooking tuxt event";
        $evh = $s->{_event};
    }
    say "line reads: $s->{value}";
    
    if ($evh) {
        if (ref $evh eq "HASH") {
            my $menu = $evh->{menu};
            my $m = $s->{menu} || $s->{value};
            if ($menu->{$m}) {
                say "hooking HASHY event menu for $m";
                $evh = $menu->{$m};
            }
            else {
            say "No '$m' amongst: ".join ", ", keys %$menu;
                return $self->{hostinfo}->error(
                "unhandled tuxt click", $s, $event);
            }
        }
        $evh->($event, $s, $self, @_);
    }
    else {
        say "Event id: ".$event->{id};
        if (!$self->{view}) {
            say join"\n", "! viewless texty without event hook:", @{$self->{lines}};
            return;
        }
        say "Texty $self->{id} $self->{view}->{divid} event heading for ".$self->{view}->{id};
        $self->view->event($event, $self);
    }
}
sub owner {
    my $self = shift;
    return $self->view;
}


1;

