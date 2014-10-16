package Codon;
use strict;
use warnings;
use Scriptalicious;
use File::Slurp;
use HTML::Entities;

our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    my $p = shift;
    
    $self->{codo} = $p->{codo};
    
    
    if (my $f = $p->{filename}) {
        $self->{mtime} = (stat $f)[9];
        $self->open_filename($f);
    }
    $p->{o} ? $self->o($p->{o}) : $self->closed_o();

    $self;
}
sub open_filename {
    my $self = shift;
    my $f = $self->{filename} = shift;
    die "no such codon file: $f" unless -f $f;
    
    ($self->{style}, $self->{stylefile}) = $f =~
        /style(\w+)\/(.+)$/;
        
    my $sf = $self->{stylefile};
    
    $self->{is} = {};
    $self->{name} =
    $sf ?
        do {
             $sf =~ /ghosts\/(\w)\w*\/(.+)$/ ?
                 do { $self->{is}->{G} = 1; "$1/$2" }
             :
             $sf =~ /lib\/(\w+)\.pm$/ ?
                 do { $self->{is}->{P} = 1; $1 }
             :
             $sf =~ /^not$/ ?
                 do { $self->{is}->{N} = 1; $sf }
             :
             $sf
        }
        :    
        $self->{filename};
    
    $self->open_codefile();
    
    $self->chunkify();    
}
sub o {
    my $self = shift;
    $self->{openness} = shift if @_;
    $self->{openness} ||= {};
}
sub closed_o {
    my $self = shift;;
    my $o = $self->o;
    $o->{$_} = "Closed" for 0..scalar(@{$self->{chunks}})-1;
}
sub ddump { Hostinfo::ddump(@_) }
sub open_codefile {
    my $self = shift;
    $self->{lines} = [
        map { s/\n$//s; $_ }
        split "\n",
        $self->readfile($self->{filename})
    ];
}
sub display {
    my $self = shift;
    my $codo = shift;
    my $ope = shift;
    if ($ope) {
        $self->{openness} = $ope;
    }

    my $divid = $self->{id};
    my $name = $self->{name};
    $name =~ s/^ghosts\/(.+)\/(.+)$/<t style="font-size:33pt; font-family:cursive;display:inline;">G<\/t><t style="color:#63D13E">$1<\/t><t style="font-size:53pt; font-family:monospace;display:inline;">$2<\/t>/;
    my $head = '!html <span style="text-shadow: 2px 3px 40px #FFFFFF;color:#66CCFF;font-size:58pt; z-index:20; position: absolute: top:-30px;" id="<<ID>>-Head">'.$name.'</span>';

    my $show = $self->{show} ||= do {
        $codo->{Codo}->spawn_floozy($self, $divid, "width:100%; background:#80182; color:#afc; height:23em;");
    };

    my $texty = $self->{text} = $show->text;

    my $temp = $codo->{temp} ||= $self->{hostinfo}->{flood}->spawn_floozy($self,
        temp => "width:89%; height:1em; background: #0c8; color: #362;",
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
            $rows = 5 if $rows < 5;

            if ($ness eq "Open") {
                my $tempid = $texty->{id}."-Temp-$i";
                my $textid = $texty->{id}."-Text-$i";
                $texty->hostinfo->send("\$('#$temp->{divid}').append('<span id=\"$tempid\"></span>');");
                $texty->hostinfo->send("\$('#$textid').appendTo('#$tempid');");
            }

            push @chunks,
"!html !i=$i "
.'<textarea name="code" onfocus="clickoff();" onblur="clickon();" id="<<ID>>-Text-'.$i.'" cols="57" rows="'.$rows.'" style="background-color: #08b;"></textarea>'
.'<span id="<<ID>>-Close-'.$i.'" style="position: absolute; right: -10px; opacity: 0.4; top: 0em; font-size: 32pt; z-index: 20;">@</span>'
.'<span id="<<ID>>-Close-'.$i.'" style="position: absolute; right: -10px; opacity: 0.4; bottom: 0em; font-size: 32pt; z-index: 20;">@</span>'
.'<span id="<<ID>>-Colour-'.$i.'" style="position: absolute; right: 0.7em; opacity: 0.4; bottom: 0.5em; font-size: 16pt; z-index: 20;">c</span>'
.'<span id="<<ID>>-Collapse" style="position: absolute; right: 1.6em; opacity: 0.4; top: 1.6em; font-size: 8pt; z-index: 20;">z</span>'
        }
        elsif ($ness eq "Closed" || $ness eq "Closing") {
            # closed
            push @chunks, $self->draw_chunk($c);
        }
    }

    $texty->replace([ map { $_ } $head, @chunks, scalar(@chunks)." chunks"]);

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
        if ($self->{openness}->{$i} eq "Open") { #c
            my $textid = $texty->{id}."-Text-$i";
            my $he = int(((250 / 15) * $1)) if $s->{value} =~ /rows="(\d+)"/;
            $he ||= 42;
            my $theme = $self->{name} =~ /^ghosts\// ? "base16-dark" : "midnight";
            $self->{hostinfo}->JS(
<<CM
    var cm = CodeMirror.fromTextArea(document.getElementById('$textid'), {
    mode: 'perl',
    theme: '$theme',
    lineWrapping: true,
    extraKeys: {
        'F9': function(cm) {
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
        }
    }
    my $cmback = ".$texty->{id} > .CodeMirror";
    $H->{G}->timer(1, sub {
    $H->{G}->HGf('H/colour')->w(Arr =>
        {name => "Codon/$self->{name}",
        set_css_background => $cmback,
        force_set => 1}
    );
    });
    $H->JS("\$('$cmback').css('width', '100%').css('height', 'auto').css('overflow', 'visible');");
    $H->JS("\$('.CodeMirror').parent().css('width', '99%');");

    $temp->wipehtml() if $temp;

    $texty->fit_div;
}
sub draw_chunk {
    my $self = shift;
    my $c = shift;
    my $first = $c->{lines}->[0];
    
    $first =~ s/^(.{65}).+$/$1.../;
    $first = encode_entities($first);

$first =~ s/(sub|function|package| ) (\S+) /$1<t
    style="font-size:33pt; font-family:cursive;display:inline;"> $2 <\/t>/;
    return "!html !i=$c->{i} $first"
        .($c->{rows} > 1 ? " ~ $c->{rows}" : "")
}
our @personalities = (
sub { int rand 123 },
sub { int rand 255 },
sub { 100 + int rand 155 },
);
sub random_colour {
    if (shift) {
        push @personalities, shift @personalities;
    }
    my ($as) = @personalities;
    my ($rgb) = join", ", map {$as->()} 1 .. 3;
    return "rgb($rgb)";
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
    elsif ($id =~ /-Collapse/) {
        $self->save_all("Collapse");
    }
    elsif ($id =~ /^(.+)-Colour-(\d+)$/) {
        my ($tid, $cid) = ($1, $2);
        my $fid = "$tid-".($cid+1);
        $H->{G}->HGf('colour')->w(Arr =>
            {name => "Codon/$self->{name}", change => 'change', e => $e},
        );
        #my $colour = random_colour($e->{C});
        #$H->JS("\$('#$fid > div').animate({backgroundColor: '$colour'}, 200);");
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
    $self->{Going} = shift || 1;
    $self->save_all();
}
sub readfile {
    my $self = shift;
    return $self->{hostinfo}->getapp("Codo")->readfile(@_);
}
sub writefile {
    my $self = shift;
    return $self->{codo}->writefile(@_);
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

    $self->writefile($self->{filename}, $whole);

    $self->save_done;
}
sub save_done {
    my $self = shift;
    if ($self->{Going}) {
        say "Codon $self->{name} is going away";
        $self->sleeep();
        if ($self->{show}) {
            "nolobo" eq $self->{Going} ?
                $self->{show}->HIDEHIDEHIDE() # no anim
              : $self->{show}->nah()
        }
        delete $self->{show};
        $self->{codo}->lobo($self)
            unless
                "nolobo" eq delete $self->{Going};
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

    my @stuff = ([]);
    # this consumes lines, should do wormhole at the end of init_wormhole
    my @lines = @$lines;
        while (defined(my $l = shift @lines)) {
            push @stuff, []
            if
            $self->{is}->{G} ?
                @{$stuff[-1]} > 0 && $l =~ /^\w+|^  \w+/
                || $l =~ /#c/
            :
            !$self->{is}->{N} ?
                $l =~ /^\S+.+ \{(?:\s+\#.+?)?$/gm
                || $l =~ /#c/
            : 0;
            
            push @{ $stuff[-1] }, $l;
            
            if ($self->{is}->{N}) {
                push @stuff, [] if $l eq '' && $lines[0] ne '';
            }
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

