package Codon;
use strict;
use warnings;
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

    $self->chunkify();

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
        $codo->{coshow}->spawn_floozy($self, $divid, "width:89%; background:#202a15; color:#afc; height:23em;");
    };

    my $texty = $self->{text} = $show->text;

    my $temp = $codo->{temp} ||= $self->{hostinfo}->{flood}->spawn_floozy($self,
        temp => "width:89%; height:13em; background: #fc8; color: #362;",
    )
        if grep { $self->{openness}->{$_} eq "Open" } keys %{ $self->{openness} };

    my @chunks;
    for my $c (@{$self->{chunks}}) {
        my $i = $c->{i};
        my $lines = $c->{lines};
        my $rows = scalar(@$lines);
        my $ness = $self->{openness}->{$i};

        if ($ness =~ /^Open/) {
            $rows = 25 if $rows > 25;
            $rows = 1 if $rows < 1;

            if ($ness eq "Open") {
                my $tempid = $texty->{id}."-Temp-$i";
                my $textid = $texty->{id}."-Text-$i";
                $texty->hostinfo->send("\$('#$temp->{divid}').append('<span id=\"$tempid\"></span>');");
                $texty->hostinfo->send("\$('#$textid').appendTo('#$tempid');");
            }

            push @chunks,
                "!html !i=$i "
                .'<textarea name="code" onfocus="clickoff();" onblur="clickon();" id="<<ID>>-Text-'.$i.'" cols="77" rows="'.$rows.'" style="background-color: #a8b;"></textarea>'
                .'<input id="<<ID>>-Close-'.$i.'" type="submit" value="C">'
                .'<input id="<<ID>>-Save-'.$i.'" type="submit" value="S">'
        }
        elsif ($ness eq "Closed" || $ness eq "Closing") {
            # closed
            push @chunks,
                "!i=$i $c->{first} ($rows lines)";
        }
    }

    $texty->replace(["!html !wtf=head <h2>$self->{name}</h2>", @chunks, scalar(@chunks)." chunks"]);

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
            $self->{hostinfo}->send(
                "\$('#$show->{divid} #$textid').replaceWith(\$('#$tempid #$textid'));"
            );
        }
        elsif ($ness eq "Closed") {
            # has it all
        }
        elsif ($ness eq "Closing") {
            $self->{hostinfo}->send(
                "\$('#$s->{id}').animate({ fontSize: '3em' }, 0).animate({ fontSize: '1em' }, 400);"
            );
            $self->{openness}->{$i} = "Closed";
        }
        else {
            my $lines = $c->{lines};
            my $code = join "\n", @$lines;
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g; # the escape is interpolated in JS string after the websocket
            say "Codon $self->{name} [$i] is opening     (".scalar(@$lines)." lines)";
        }
    }

    $temp->wipehtml() if $temp;

    $texty->fit_div;
}

sub event {
    my $self = shift;
    my $e = shift;
    my $id = $e->{id};
    my $s = $self->{text}->id_to_tuxt($id); # LIES
    my $i = $s->{i} if $s;
    
    if ($id =~ /-Save-(\d+)$/) {
        $i = $1;
        say "Codon $self->{name} SAVE $i";
        $self->save_chunk($i);
    }
    elsif ($id =~ s/-Close-(\d+)$//) {
        $i = $1;
        say "Codo > > > close < < < $self->{name} chunk $i";

        $self->save_chunk($i);

        $self->{openness}->{$i} = "Closing";

        $self->display();
    }
    elsif ($id && $id =~ /Text-\d+/) {
        say " clicked textarea or so";
    }
    elsif ($s && defined $i) {
        say "Codo\t\t$self->{name}\t\t OP E  N $i";

        $self->{openness}->{$i} = "Opening";

        $self->display();
    }
    else {
        say "Codo $self->{name} event want something else?";
        say ddump([$s, $i, $e]);
    }
}

sub away {
    my $self = shift;

}

sub readfile {
    my $self = shift;
    return $self->{hostinfo}->getapp("Codo")->readfile(@_);
}

sub writefile {
    my $self = shift;
    return $self->{hostinfo}->getapp("Codo")->writefile(@_);
}

sub save_all {
    my $self = shift;
    my $sv = $self->{saving} = {};
    while (my ($i, $ness) = each %{ $self->{openness} }) {
        if ($ness eq "Open") {
            $self->{saving}->{$i} = 1;
            $self->save_chunk($i)
        }
    }
    say "\n\nnothing in $self->{name} is Open\n\n" unless %$sv;
}

sub save_chunk {
    my $self = shift;
    my $i = shift;

    my $textid = $self->{text}->{id}."-Text-$i";

    my $sec = $self->{hostinfo}->claw_add( sub {
        my $e = shift;
        $self->update_chunk($i => decode_entities($e->{code}));
    } );

    $self->{hostinfo}->send(
         "  ws.reply({claw: '$sec', code: \$('#$textid').val()}); "
    );
}

sub update_chunk {
    my $self = shift;
    my $i = shift;
    my $code = shift;
    my $c = $self->{chunks}->[$i];

    $c->{lines} = [ split("\n", $code), "" ];
    
    say "Codon $self->{name} $i came along,  ".scalar(@{$c->{lines}})."x".length($code);

    if ($self->{saving}) {
        delete $self->{saving}->{$i} || die "wtf";
        if (keys %{ $self->{saving} }) {
            say " more chunks awaiting...";
            return;
        }
        delete $self->{saving};
        $self->{Gone} = $self->{hostinfo}->hitime();
    }

    say "Going to write $self->{name}";

    my $lines = [];
    for my $c (@{ $self->{chunks} }) {
        push @$lines, @{$c->{lines}};
    }
    my $whole = join "\n", @$lines;
    $whole .= "\n" unless $whole =~ /\n$/s;

    $self->writefile($self->{codefile}, $whole);
    
    $self->open_codefile();
    
    $self->chunkify();
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub chunkify {
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
