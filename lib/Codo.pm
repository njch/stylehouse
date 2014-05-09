package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
=pod

Devel::ebug interface
slurpy other programs

Codo is for ghosting ghosts.
fishing around in the void.
flip through stuff.
so you can say, go here, what's this, watch this, find the pathway of its whole existence

context richness.

form.

and then they build 1s as Codons (genetic model for something like a travel/ghost/wormhole coupling)
where layers can be injected in space anywhere without breaking the fabric of it
right now time is not something we can flop out anywhere, depending on what we're going for
take that morality

=cut

has 'hostinfo';
sub ddump { Hostinfo::ddump(@_) }
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub DESTROY {
    my $self = shift;
    $self->nah;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{run} = $self->hostinfo->get_view($self, run => "hodi");

    $self->{hostinfo}->provision_view(codonmenu => "width:58%;  background: #301a30; color: #afc; height: 60px;");
    $self->{codonmenu} = $self->hostinfo->get_view($self, "codonmenu");
    $self->{codonview} = $self->hostinfo->get_view($self, "codonview" => "hodu");

    $self->{obsetrav} = $self->hostinfo->set("Codo/obsetrav", []); # observations of travel

    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    $self->init_wormcodes(
        qw(ebuge.pl stylehouse.pl),
        glob("lib/*.pm"),
        glob("ghosts/*/*"),
    );

    $self->init_codemenu();

    return $self;
}

sub menu { # {{{
    my $self = shift;
    my $menu = {};
    $menu->{"nah"} = sub { $self->nah };
    $menu->{"new"} = sub { $self->new_ebuge() };
    $menu->{"<views>"} = sub {
        say "Sending view dump\n\n";
        $self->{run}->text->replace(["!html <h2>views</h2>", split "\n", ddump($self->hostinfo->get("screen/views/*"))]);
    };
    $menu->{"<obso>"} = sub {
        say "Sending obsotrav dump\n\n";
        $self->{run}->text->replace(["!html <h2>obsetrav</h2>", split "\n", ddump($self->hostinfo->get("Codo/obsetrav"))]);
    };

    return $menu;
}

sub init_codemenu {
    my $self = shift;

    $self->{codonmenu}->text([], {
        tuxts_to_htmls => sub {
            my $self = shift;
            for my $s (@{$self->tuxts}) {
                my $code = $s->{value};
                # say "A menu for $code->{name} ".join", ", keys %$code;
                $s->{value} = $code->{name};
                $s->{origin} = $code;
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
            }
        },
        spatialise => sub {
            return { horizontal => 40 } # space tabs by 40px
        },
    });

    $self->{codonmenu}->text->replace($self->{codes});
} # }}}

sub load_codon {
    my $self = shift;
    my $codon = shift;
    $codon = $self->codon_by_name($codon) unless ref $codon;
    say "Load Codon for $codon->{name}";

    my $text = $self->{codonview}->text;

    $self->{currodon} = $codon;
    $codon->display($text);

    say "Done.\n\n\n";
}

sub update_currodon { # just one chunk, whatevery
    my $self = shift;
    my $chunki = shift;
    my $code = shift;
    my $codon = $self->{currodon};
    $codon->update($chunki, $code);
}

sub codon_by_name {
    my $self = shift;
    my $name = shift;
    my ($code) = grep { $_->{name} eq $name } @{ $self->{codes} };
    $code;
}

{   package Codon;
    use File::Slurp;
    sub new {
        my $self = bless {}, shift;
        shift->($self);
        $self->{points} = shift || { 1 => 1 };
        $self;
    }
    sub display {
        my $self = shift;
        my $texty = shift;

        my $chunks = $self->{chunks};

        my @bits = (
            "!html <h2>$self->{name}</h2>"
        );
        my @open = ();

        for my $i (sort keys %$chunks) {
            my $v = $chunks->{$i};
            my $lines = $v->{lines};
            my $rows = scalar(@$lines);
            say "$i chunk";
            if ($self->{points}->{$i}) {
                # open
                my $code = join "\n", @{$v->{lines}};
                $code =~ s/"/\\"/g;
                $code =~ s/\n/\\n/g;
                say "$i Code is $rows lines\t\t$v->{first}";
                $rows = 20 if $rows > 25;
                push @bits,
                    '!html !chunki='.$i.' '
                    .'<textarea name="code" id="<<ID>>-ta" cols="77" rows="'.$rows.'"></textarea>'
                    .'<input id="<<ID>>-up" type="submit" value="sav">'
            }
            else {
                # closed
                push @bits, $v->{first}." ($rows lines)";
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
            $n->{style} .= "border: 1px solid black;";
            $n;
        };
        $texty->{hooks}->{tuxts_to_html} = sub {
            my $self = shift;
            $self->{tuxts} = [
                map { $_->{chunki} ? ($_, $apo->("up", $_, 10), $apo->("x", $_, 30)) : $_ } @{$self->{tuxts}}
            ];
        };
        $texty->replace([
            @bits
        ]);

        for my $s (@{ $texty->{tuxts} }) { # go through adding other stuff we can't throw down the websocket all at once
            my $id = $s->{id};
            my $i = $s->{chunki} || next;
            my $c = $chunks->{$i};
            say Codo::ddump($c);
            my $lines = $c->{lines};
            my $code = join "\n", @$lines;
            $code =~ s/"/\\"/g;
            $code =~ s/\n/\\n/g; # the escape is evaporated in JS string after the websocket
            say "Chunk $i is open to ".scalar(@$lines)." lines";
            $self->{hostinfo}->send(qq{\$('#$id-ta').append("$code"); }); # this could be partitioned easy
        }
    }
    sub upload {
        my $self = shift;
        my $id = shift;
        my $sec = $self->{hostinfo}->claw_add( sub {
            my $e = shift;
            my $id = $e->{id};
            my $tuxt = $self->{text}->id_to_tuxt($id);
            my $chunki = $tuxt->{chunki} || die;
            $self->update_currodon($chunki => $e->{code}); # only one codon on screen at a time, build fancier shit? can probably work around it fine.
        } );
        $self->{hostinfo}->send(
             "  ws.reply({claw: '$sec', id: '$id', code: document.getElementById('$id-ta').innerHTML}); "
        );
    }
    sub update {
        my $self = shift;
        my $i = shift;
        my $code = shift;
        my $chunks = $self->{chunks};

        $chunks->{$i}->{lines} = $code;

        my $lines = [];
        for my $i (sort keys %$chunks) {
            my $v = $chunks->{$i};
            push @$lines, split "\n", $chunks->{$i}->{lines};
        }
        write_file($self->{codefile}, join "\n", @$lines);
        $self->chunk();
    }
    sub load_file {
        my $self = shift;
        $self->{lines} = [map { $_ =~ s/\n$//s; $_ } read_file($self->{codefile})];
        $self->chunk();
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

        my $chunks;
        my $i = 0;
        for my $s (@stuff) {
            $chunks->{$i} = {
                first => $s->[0],
                length => @$s-1,
                lines => $s,
            };
            $i++;
        }
        $self->{chunks} = $chunks;
    }
}

# get the forms of that clouds of ghosts (more formation in Codon::chunk())
sub init_wormcodes {
    my $self = shift;
    my @codefiles = @_;

    for my $cf (@codefiles) {
        my $name = (($cf =~ /(\w+).pm$/)[0] || $cf);
        my $codon = $self->codon_by_name($name);
        my $isnew = 1 if !$codon;

        my $mtime = (stat $cf)[9];

            if ($isnew) {
                $codon = new Codon($self->hostinfo->intro);
                $codon->{codefile} = $cf;
                $codon->{name} = $name;
                $codon->{mtime} = $mtime;
            }

        if ($codon->{mtime} < $mtime) {
            say "$cf changed";
            $codon->{mtime} = $mtime;
            $isnew = 1;
        }

            if ($isnew) {
                $codon->load_file();
                push @{ $self->{codes} }, $codon;
                say "new Codon: $codon->{name}\t\t".scalar(@{$codon->{lines}})." lines";
            }
    }
}


sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    my $codemenutexty = $self->ports->{codonmenu}->menu->text;
    my $codetexty =     $self->ports->{codonview}->text;

    # CODE ACTION
    if ($id =~ /-ta$/) {
        return;
    }
    if ($id =~ s/-up$//) {
        $self->{currodon}->upload($id);
        return;
    }
    if ($id =~ s/-close$//) {
        my $tuxt = $codetexty->id_to_tuxt($id);
        my $chunki = $tuxt->{chunki} || die;
        my $codon = $self->{currodon};
        $codon->{points}->{$chunki} = 0;
        $codon->display;
    }


    # CODE EXPAND
    if (my $tuxt = $codetexty->id_to_tuxt($id)) {
        say "Code click got: ".ddump($tuxt);
        say "TODO" for 1..3;
        return;
    }


    # MENU
    if (my $tuxt = $codemenutexty->id_to_tuxt($id)) {
        if (ref $tuxt->{origin} eq "Codon") {
            return $self->load_codon($tuxt->{origin});
        }
    }
    else {
        return $self->hostinfo->error("Codo event 404" => $id, event => ddump($event));
    }
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub nah {
    my $self = shift;
    for my $ebuge (@{ $self->ebuge }) {
        unless ($ebuge) {
            say "weird, no ebuge...";
            next;
        }
        $ebuge->nah;
    }
    $self->ebuge([]);
}

sub new_ebuge {
    my $self = shift;
    my $ebuge = Ebuge->new($self->hostinfo->intro, "ebuge.pl");
    push @{ $self->ebuge }, $ebuge;
    return $ebuge;
}
1;
