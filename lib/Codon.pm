package Codon;
use Scriptalicious;
use File::Slurp;
use HTML::Entities;

sub new {
    my $self = bless {}, shift;
    shift->($self);
    my $p = shift;
    for my $k (keys %$p) {
        $self->{$k} = $p->{$k};
    }
    $self->open_codefile();
    $self;
}
sub ddump { Hostinfo::ddump(@_) }

sub open_codefile {
    my $self = shift;
    $self->{lines} = [map { $_ =~ s/\n$//s; $_ } $self->readfile($self->{codefile})];
    $self->chunk();
}

sub display {
    my $self = shift;

    $self->{openness} ||= {};

    my $texty = $self->{text} || die "NO Texty set into $codon->{name} before ->display";

    my @bits = (
        "!html <h2>$self->{name}</h2>"
    );

    my $chunks = $self->{chunks};
    for my $v (@$chunks) {
        my $i = $v->{i};
        my $lines = $v->{lines};
        my $rows = scalar(@$lines);
        if ($self->{openness}->{$i}) {
            # open
            my $code = join "\n", @{$v->{lines}};
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g;
            $code =~ s/\t/\\t/g;
            say "$i Code is $rows lines\t\t$v->{first}";
            $rows = 25 if $rows > 25;
            $rows = 1 if $rows < 1;
            my $style = "background-color: #a8b;";
            push @bits,
                '!html !chunki='.$i.' !textarea=1 '
                .'<textarea name="code" id="<<ID>>-ta" cols="77" rows="'.$rows.'" style="'.$style.'"></textarea>'
                .'<input id="<<ID>>-up" type="submit" value="sav">'
        }
        else {
            # closed
            if ($self->{last_openness} && $self->{last_openness}->{$i}) {
                say " TODO potentially losing stuff from unsaved chunk by reducing openness";
            }
            push @bits, "!chunki=$i $v->{first} ($rows lines)";
        }
    }

    my $apo = sub {
        my $t = shift;
        my $s = shift;
        my $top = shift;
        my $n = { %$s };
        $n->{id} .= "-$t";
        $n->{left} -= 20;
        $n->{toppy} += $top;
        $n->{value} = $t;
        delete $n->{htmlval};
        $n->{style} .= "border: 1px solid black;";
        $n;
    };
    $texty->{hooks}->{tuxts_to_html} = sub {
        my $self = shift;
        my @new;
        for my $t (@{$self->{tuxts}}) {
            if ($t->{textarea}) {
                push @new, $apo->("up", $t, 10);
                push @new, $apo->("x", $t, 30);
            }
            push @new, $t;
        }
        $self->{tuxts} = \@new;
    };
    $texty->{origin} = $self; # as $Codo->{the_codon} but not singular
    
    my $divid = $texty->view->{divid};
    my $hooks = {};
    my $lastuxts;
    if ($self->{last_openness}) {
        say "going to re-id and hide $texty->{id}";
        $hooks->{append} = "temp";
        $lasttuxts = $texty->{tuxts};
    }

    my $temp = $texty->replace([@bits], $hooks);

    my $tid = $temp->{tempid} if $temp;
    if ($self->{last_openness}) {
        $tid || die "no temp from replace()";
    }
    
    for my $s (@{ $texty->{tuxts} }) { # go through adding other stuff we can't throw down the websocket all at once
        next unless $s->{textarea};
        my $id = $s->{id};
        my $i = $s->{chunki};
        my $c = $chunks->[$i];
        if ($tid && $self->{last_openness}->{$i}) { # already open from last time, copy shit across on the client
            my ($oldtuxt) = grep { $_->{chunki} == $i } @$lasttuxts;
            my $oid = $oldtuxt->{id};
            say "Codon $self->{name} [$i] is still open, copying around...";
            my $tid = $temp->{tempid}; # is invisible span containing old spans
            $self->{hostinfo}->send(qq{  \$('#$divid > #$id > #$id-ta').text(  \$('#$divid > #$tid > #$oid > #$oid-ta').val()  );  });
        }
        else {
            my $lines = $c->{lines};
            my $code = join "\n", @$lines;
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g; # the escape is interpolated in JS string after the websocket
            say "Codon $self->{name} [$i] is opening     (".scalar(@$lines)." lines)";
            $self->{hostinfo}->send(qq{  \$('#$divid > #$id > #$id-ta').text("$code");  }); # this could be partitioned using .append()s139G
        }
    }

    if ($tid) { # remove the temp data - this be a tractor once textys are geometrica
        $self->{hostinfo}->send(qq{  \$('#$divid > #$tid').remove();  });
    }
    if (%{ $self->{openness} }) {
        $self->{last_openness} = { %{ $self->{openness} } };
    }

    $texty->{max_height} = 1000;
    $texty->fit_div;
}

sub unload {
    my $self = shift;
    $self->{chunks_unload} = {};
    my $tuxts = $self->{text}->{tuxts};
    for my $t (@$tuxts) {
        next unless $t->{textarea};
        my $i = $tuxt->{chunki};
        $self->{chunks_unload}->{$i} = 1;
        $self->up_load($t->{id});
        say "try up_load $i";
    }
}

sub readfile {
    my $self = shift;
    return $self->{hostinfo}->getapp("Codo")->readfile(@_);
}

sub writefile {
    my $self = shift;
    return $self->{hostinfo}->getapp("Codo")->writefile(@_);
}

sub up_load { # precursor to update
    my $self = shift;
    my $id = shift;
    my $sec = $self->{hostinfo}->claw_add( sub {
        my $e = shift;
        my $id = $e->{id};
        my $tuxt = $self->{text}->id_to_tuxt($id);
        my $chunki = $tuxt->{chunki};
        $self->update($chunki => decode_entities($e->{code})); # only one codon on screen at a time, build fancier shit? can probably work around it fine.
    } );
    $self->{hostinfo}->send(
         "  ws.reply({claw: '$sec', id: '$id', code: \$('#$id-ta').val()}); "
    );
}

sub update {
    my $self = shift;
    my $i = shift;
    my $code = shift;
    my $chunks = $self->{chunks};

    my $before = scalar(@{$chunks->[$i]->{lines}});
    $chunks->[$i]->{lines} = [ split "\n", $code ];
    my $after = scalar(@{$chunks->[$i]->{lines}});
    
    say "Codon $self->{name} \t$self->{codefile}\tchunk $i line count $before -> $after";

    if ($self->{Going}) {
        delete $self->{chunks_unload}->{$i} || die "wtf";
        if (keys %{ $self->{chunks_unload} }) {
            say " more chunks awaiting...";
            return;
        }
        delete $self->{chunks_unload};
        $self->{Gone} = $self->{hostinfo}->hitime();
    }

    my $lines = [];
    for my $v (@$chunks) {
        push @$lines, @{$v->{lines}};
    }
    my $whole = join "\n", @$lines;
    $whole .= "\n" unless $whole =~ /\n$/s;
    $self->writefile($self->{codefile}, $whole);
    $self->chunk();
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub chunk {
    my $self = shift;
# supposed to be a Tractor doing this

    my $lines = $self->{lines};

    # this consumes lines, should do wormhole at the end of init_wormhole
    my @stuff = ([]);
    for my $l (@$lines) {
        if ($l =~ /^\S+.+ \{$/gm) {
           push @stuff, [];
        }
        push @{ $stuff[-1] }, $l;
    }

    my $chunks = [];
    my $i = 0;
    for my $s (@stuff) {
        push @$chunks, {
            i => $i++,
            first => $s->[0],
            length => @$s-1,
            lines => $s,
        };
    }
    $self->{chunks} = $chunks;
}

1;
