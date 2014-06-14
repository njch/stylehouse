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

    if ($self->{codefile}) {
        $self->open_codefile();
    }
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
    my $ope = shift;
    if ($ope) {
        $self->{openness} = $ope;
    }

    my $divid = $self->{id};

    my $show = $self->{show} ||= do {
        $codo->{Codo}->spawn_floozy($self, $divid, "width:89%; background:#202a15; color:#afc; height:23em;");
    };

    my $texty = $self->{text} = $show->text;

    my $temp = $codo->{temp} ||= $self->{hostinfo}->{flood}->spawn_floozy($self,
        temp => "width:89%; height:1em; background: #fc8; color: #362;",
    )
        if grep { $self->{openness}->{$_} eq "Open" } keys %{ $self->{openness} };

    my @chunks;
    for my $c (@{$self->{chunks}}) {
        my $i = $c->{i};
        my $lines = $c->{lines};
        my $rows = scalar(@$lines);
        my $ness = $self->{openness}->{$i} ||= "Opening";

        if ($ness =~ /^Open/) {
            $rows = 105 if $rows > 105;
            $rows = 2 if $rows < 2;

            if ($ness eq "Open") {
                my $tempid = $texty->{id}."-Temp-$i";
                my $textid = $texty->{id}."-Text-$i";
                $texty->hostinfo->send("\$('#$temp->{divid}').append('<span id=\"$tempid\"></span>');");
                $texty->hostinfo->send("\$('#$textid').appendTo('#$tempid');");
            }

            push @chunks,
                "!html !i=$i "
                .'<textarea name="code" onfocus="clickoff();" onblur="clickon();" id="<<ID>>-Text-'.$i.'" cols="77" rows="'.$rows.'" style="background-color: #a8b;"></textarea>'
                .'<input id="<<ID>>-Close-'.$i.'" type="submit" style="position: absolute; right: -25px; opacity: 0.4; top: 0%; height: 45%;" value="C">'
                .'<input id="<<ID>>-Save-'.$i.'" type="submit" style="position: absolute; right: -25px; opacity: 0.4; top: 55%; height: 45%;" style="position: absolute; right: -20px; top: 10px; height: 30px;" value="S">'
        }
        elsif ($ness eq "Closed" || $ness eq "Closing") {
            # closed
            push @chunks, $self->draw_chunk($c);
        }
    }

    $texty->replace([ map { $_ } '!html <h2 id="<<ID>>-Head">'.$self->{name}.'</h2>', @chunks, scalar(@chunks)." chunks"]);

    for my $s (@{ $texty->{tuxts} }) { # go through adding other stuff we can't throw down the websocket all at once
        my $id = $s->{id};
        my $i = $s->{i};
        next unless defined $i;
        my $c = $self->{chunks}->[$i];
        my $lines = $c->{lines};
        my $code = join "\n", @$lines, "";
        $code =~ s/\\/\\\\/g;
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
            die "WTF";
        }
        if ($self->{openness}->{$i} eq "Open") {
            my $textid = $texty->{id}."-Text-$i";
            my $he = int(((250 / 15) * $1)) if $s->{value} =~ /rows="(\d+)"/;
            $he ||= 42;
            my $theme = $self->{name} =~ /^ghosts\// ? "night" : "midnight";
            $self->{hostinfo}->JS(
<<CM
var cm = CodeMirror.fromTextArea(document.getElementById('$textid'), {
    mode: 'perl',
    theme: '$theme',
    lineWrapping: true,
    extraKeys: {
        'F11': function(cm) {
          cm.setOption("fullScreen", !cm.getOption("fullScreen"));
        },
        "Esc": function(cm) {
          if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
          cm.save();
          ws.reply({event:{id:"$texty->{id}-Save-$i"}})
        }
    }
});
 cm.setSize(579, $he);
 cm.on('blur', function() { cm.save(); ws.reply({event:{id:\"$texty->{id}-Save-$i\"}}) });

CM
            );
            $self->{hostinfo}->send(
            "\$('#$textid').change(function(){"
                ."ws.reply({event:{id:\"$texty->{id}-Save-$i\"}})"
            ."});"
            );
        }
    }

    $temp->wipehtml() if $temp;

    $texty->fit_div;
}
sub draw_chunk {
    my $self = shift;
    my $c = shift;
    my $first = $c->{lines}->[0];
    
    $first =~ s/^(.{65}).+$/$1.../;

    return "!i=$c->{i} $first"
        .($c->{rows} > 1 ? " ~ $c->{rows}" : "")
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
    elsif ($id =~ s/-Head$//) {
        $self->away();
    }
    elsif ($s && defined $i) {
        if ($self->{openness}->{$i} eq "Open") {
            say " Codon $self->{name}\tc$i\tis open, saving?";
            $self->save_chunk($i);
        }
        else {
            say " Codon $self->{name}\tc$i\tis  OP E  Ning";

            $self->{openness}->{$i} = "Opening";

            $self->display();
            $self->{codo}->mind_openness();
        }
    }
    else {
        say "Codo $self->{name} event want something else?";
        say ddump([$s, $i, $e]);
    }
}
sub away {
    my $self = shift;
    $self->{Going} = 1;
    $self->save_all();
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
    my $Collapsing = shift;
    my $sv = $self->{saving} = {};
    while (my ($i, $ness) = each %{ $self->{openness} }) {
        if ($ness eq "Open") {
            if ($Collapsing) {
                $self->{openness}->{$i} = "Closing";
                $self->{Collapsing} = 1;
            }
            $self->{saving}->{$i} = 1;
            $self->save_chunk($i)
        }
    }
    unless (%$sv) {
        say "\n\nnothing in $self->{name} is Open\n\n";
        $self->save_done();
    }
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

    $c->{lines} = [ split("\n", $code) ];
    
    say "Codon $self->{name} $i came along,  ".scalar(@{$c->{lines}})."x".length($code);
    
    my $textid = $self->{text}->{id}."-$i";
    $self->{hostinfo}->send(
        "\$('#$textid').fadeOut(200).fadeIn(100);");

    if ($self->{saving}) {
        delete $self->{saving}->{$i} || say " - wasn't updating $i but it came along anyway";
        if (keys %{ $self->{saving} }) {
            say " more chunks awaiting...";
            return;
        }
        delete $self->{saving};
        $self->{Gone} = $self->{hostinfo}->hitime();
    }

    say "Going to write $self->{name}";

    my $whole = join "\n", map { join "\n", @{$_->{lines}} } @{ $self->{chunks} };
    $whole .= "\n" unless $whole =~ /\n$/s;
    $whole =~ s/\t/    /g;

    $self->writefile($self->{codefile}, $whole);

    $self->save_done;
}
sub save_done {
    my $self = shift;
    if ($self->{Going}) {
        say "Codon $self->{name} is going away";
        $self->sleeep();
        $self->{show}->nah();
        delete $self->{show};
        delete $self->{Going};
        $self->{codo}->lobo($self);
    }
    else {
        my $olds = $self->{chunks};
        say "Codon $self->{name} is here";
        $self->open_codefile();
        $self->chunkify();
        
        if (@{$olds} != @{$self->{chunks}}
            || delete $self->{Collapsing}) {
            $self->sleeep();
            $self->display();
        }
    }
}
sub sleeep {
    my $self = shift;
    my $O = $self->{openness};
    while (my ($i, $ness) = each %$O) {
        if ($ness eq "Open") {
        $O->{$i} = "Opening"; # next time
        }
        else {
        $O->{$i} = "Closed";
        }
    }
}
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}
sub chunkify {
    my $self = shift;
# supposed to be a Tractor doing this

    my $lines = $self->{lines};
    my $isgho = $self->{name} =~ /^ghosts/; 

    my @stuff = ([]);
    my $newchunk = sub {
        my $l = shift;

        $isgho && @{$stuff[-1]} > 0 && $l =~ /^(\w+|  \S+)/
        
        || $l =~ /^\S+.+ \{(?:\s+\#.+?)?$/gm;
    };
    # this consumes lines, should do wormhole at the end of init_wormhole
    for my $l (@$lines) {
        push @stuff, [] if $newchunk->($l);
        push @{ $stuff[-1] }, $l;
    }

    my $chunks = [];
    my $i = 0;
    for my $s (@stuff) {
        push @$chunks, {
            i => $i++,
            rows => scalar(@$s),
            lines => $s,
        };
    }
    $self->{chunks} = $chunks;
}

1;
