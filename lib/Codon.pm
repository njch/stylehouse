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

    $self->chunk();

    my $o = $self->{openness} = {};
    $o->{$_} = "Closed" for 0..scalar(@{$self->{chunks}})-1;

    $self;
}
sub ddump { Hostinfo::ddump(@_) }

sub open_codefile {
    my $self = shift;
    $self->{lines} = [map { $_ =~ s/\n$//s; $_ } $self->readfile($self->{codefile})];
}

sub display {
    my $self = shift;
    my $codo = shift;

    my $divid = $self->{id};

    my $show = $self->{show} ||= do {
        say "\n New FLoozy for $divid\n\n";
        $codo->{coshow}->spawn_floozy($self, $divid, "width:58%;  background: #402a35; color: #afc; height: 60px;");
    };

    my $texty = $self->{text} = $show->text;

    if (grep { $self->{openness}->{$_} eq "Open" } keys %{ $self->{openness} }) {

        my $temp = $self->{hostinfo}->{flood}->spawn_floozy($self,
            temp => "width:100px; height:30px; background: white; color: #362; overflow: scroll;",
        )
    }

    my @chunks;
    for my $c (@{$self->{chunks}}) {
        my $i = $c->{i};
        my $lines = $c->{lines};
        my $rows = scalar(@$lines);
        my $ness = $self->{openness}->{$i};

        say "$i is $ness";
        
        if ($ness =~ /^Open/) {
            $rows = 25 if $rows > 25;
            $rows = 1 if $rows < 1;

            if ($ness eq "Open") {
                my $tempid = $texty->{id}."-Temp-$i";
                my $textid = $texty->{id}."-Text-$i";
                $texty->hostinfo->send("\$('#$temp->{divid}').append('<span id=\"$tempid\"></span>');");
                $texty->hostinfo->send("\$('#$textid').appendTo('#$tempid');");
            }

            say "Sending TEXTAREA, totally...";

            push @chunks,
                "!html !i=$i "
                .'<textarea name="code" id="<<ID>>-Text-'.$i.'" cols="77" rows="'.$rows.'" style="background-color: #a8b;"></textarea>'
                .'<input id="<<ID>>-Close-'.$i.'" type="submit" value="C">'
                .'<input id="<<ID>>-Save-'.$i.'" type="submit" value="S">'
        }
        elsif ($ness eq "Closed") {
            # closed
            push @chunks,
                "!i=$i $c->{first} ($rows lines)";
        }
    }

    say "Going to replace!!!";
    $texty->replace(["!html <h2>$self->{name}</h2>", @chunks, scalar(@chunks)." chunks"]);

    for my $s (@{ $texty->{tuxts} }) { # go through adding other stuff we can't throw down the websocket all at once
        my $id = $s->{id};
        my $i = $s->{i};
        next unless defined $i;
        my $c = $self->{chunks}->[$i];
        my $lines = $c->{lines};
        my $code = join "\n", @$lines, "";
        $code =~ s/"/\\"/g;
        $code =~ s/\n/\\n/g;
        $code =~ s/\t/\\t/g;
        my $rows = scalar(@$lines);
        my $ness = $self->{openness}->{$i};

        if ($ness eq "Opening") {
            my $textid = $texty->{id}."-Text-$i";
            $self->{hostinfo}->send(qq{  \$('#$textid').text("$code");  });
            $self->{openness}->{$i} = "Open";
        }
        elsif ($ness eq "Open") { # was Open, copy stuff cliently
            my $tempid = $texty->{id}."-Temp-$i";
            my $textid = $texty->{id}."-Text-$i";
            die unless $1 == $i;
            $self->{hostinfo}->send(
                "\$('#$show->{divid} #$textid').replaceWith('#$temp->{divid} #$textid');"
            );
        }
        elsif ($ness eq "Closed") {
            # has it all
        }
        else {
            my $lines = $c->{lines};
            my $code = join "\n", @$lines;
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g; # the escape is interpolated in JS string after the websocket
            say "Codon $self->{name} [$i] is opening     (".scalar(@$lines)." lines)";
        }
    }

    if ($tid) { # remove the temp data - this be a tractor once textys are geometrica
        $self->{hostinfo}->send(qq{  \$('#$divid > #$tid').remove();  });
    }

    $texty->{max_height} = 1000;
    $texty->fit_div;
}

sub event {
    my $self = shift;
    my $e = shift;
    my $id = $e->{id};
    my $tuxt = $self->{text}->id_to_tuxt($id);
    my $i = $tuxt->{i} if $tuxt;
    
    if ($tuxt && $i) {
        say "Codo\t\t$self->{name}\t\t OP E  N $i";

        $self->{openness}->{$i} = "Opening";

        $self->display();
    }
    elsif ($id =~ /-Save(-\d+)?$/) {
        $self->save();
    }
    elsif ($id =~ s/-Close(?:-(\d+))?$//) {
        $i ||= $1;
        say "Codo > > > close < < < $self->{name} chunk $i";

        $self->save();

        $self->{openness}->{$i} = "Closing";

        $self->display();
    }
    elsif ($id && $id =~ /Text-\d+/) {
        say " clicked textarea or so";
    }
    else {
        say "Codo $self->{name} event want something else?";
        say ddump($e);
    }
}

sub away {
    my $self = shift;

}

sub unload {
    my $self = shift;
    $self->{chunks_unload} = {};
    my $tuxts = $self->{text}->{tuxts};
    for my $t (@$tuxts) {
        next unless $t->{textarea};
        my $i = $tuxt->{i};
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

sub save { # precursor to update
    my $self = shift;
    my $id = shift;
    my $sec = $self->{hostinfo}->claw_add( sub {
        my $e = shift;
        my $id = $e->{id};
        my $tuxt = $self->{text}->id_to_tuxt($id);
        my $i = $tuxt->{i};
        $self->update($i => decode_entities($e->{code})); # only one codon on screen at a time, build fancier shit? can probably work around it fine.
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
