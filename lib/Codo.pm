package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Codon;
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

    my $style = $self->{hostinfo}->get("style");
    if ($style eq "stylehouse" && -e "../styleshed") {
        $self->{code_dir} = "../styleshed/"; # default .
    }

    $self->{run} = $self->hostinfo->get_view($self, run => "hodi");


    $self->{hostinfo}->make_view($self, codostate => "width:58%;  background: #301a30; color: #afc; height: 60px;");
    
    $self->{hostinfo}->make_view($self, codonmenu => "width:58%;  background: #402a35; color: #afc; height: 60px;");

    $self->{hostinfo}->make_view($self, codon => "width:58%;  background: #352035; color: #afc; height: 600px;");


    $self->{obsetrav} = $self->hostinfo->set("Codo/obsetrav", []); # observations of travel

    $self->{codes} = $self->hostinfo->get("Codo/codes")
                  || $self->hostinfo->set("Codo/codes", []);

    
    my $m = $self->{menu} = {};
    $m->{"nah"} = sub { $self->nah };
    $m->{"new"} = sub { $self->new_ebuge() };
    $m->{"<views>"} = sub {
        say "Sending view dump\n\n";
        $self->{run}->text->replace(["!html <h2>views</h2>", $self->hostinfo->dkeys]);
    };
    $m->{"<obso>"} = sub {
        say "Sending obsotrav dump\n\n";
        $self->{run}->text->replace(["!html <h2>obsetrav</h2>", split "\n", ddump($self->hostinfo->get("Codo/obsetrav"))]);
    };
    $m->{"R"} = sub {
        $self->{codostate}->text->replace(["!html <h4>restarting (if)</h4>"]);
        `touch $0`;
    };


    $self->init_wormcodes();

    $self->init_codemenu();

    return $self;
}

sub menu { # {{{
    my $self = shift;
    $self->{menu};
}

sub list_of_codefiles {
    my $self = shift;
    my $dir = $self->{code_dir} || "";
    grep { !$dir || s/^$dir// } (
        glob($dir.'stylehouse.*'),
        glob($dir.'public/stylehouse.*'),
        glob($dir.'lib/*.pm'),
        glob($dir.'ghosts/*/*'),
    );
}

sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    my $codon_menu_texty = $self->ports->{codonmenu}->text;
    my $codon_texty =      $self->ports->{codon}->text;

    # CODE ACTION
    if ($id =~ /-ta$/) {
        return;
    }
    if ($id =~ s/-up$//) {
        $self->{the_codon}->up_load($id); # to get rid of the_codon singularity lookup the texty->{origin}
        return;
    }
    if ($id =~ s/-close$//) {
        my $tuxt = $codon_texty->id_to_tuxt($id);
        my $ci = $tuxt->{chunki};
        die "no chunki on ".ddump($tuxt) unless defined $ci; # this kinda shit is so obvious   /// --- \\\
        my $codon = $self->{the_codon} || die "no codoon?";
        say "Codo > > > close < < < $codon->{name} chunk $ci";
        $codon->{openness}->{$ci} = 0;
        $codon->display();
        return;
    }


    # CODE OPEN
    if (my $tuxt = $codon_texty->id_to_tuxt($id)) { # entire texty vision of the chunk should lead here if it gets complicated
        my $ci = $tuxt->{chunki};
        die "no chunki on ".ddump($tuxt) unless defined $ci; # this kinda shit is so obvious   /// --- \\\
        my $codon = $self->{the_codon} || die "no codoon?";
        say "Codo < < < OPEN > > > $codon->{name} chunk $ci";
        $codon->{openness}->{$ci} = 1;
        $codon->display();
        return;
    }


    # MENU
    if (my $tuxt = $codon_menu_texty->id_to_tuxt($id)) {
        if (ref $tuxt->{origin} eq "Codon") {
            return $self->load_codon($tuxt->{origin});
        }
    }
    else {
        return $self->hostinfo->error("Codo event 404 for $id" => $event);
    }
}

# get the forms of that clouds of ghosts (more formation in Codon::chunk())
sub init_wormcodes {
    my $self = shift;

    say "INIT WORMCODES!";
    my @codefiles = $self->list_of_codefiles();

    for my $cf (@codefiles) {
        my $name;
        ($name) = $cf =~ /\/?((?:ghosts|wormholes)\/\w+\/.+)$/ unless $name;
        ($name) = $cf =~ /\/?(\w+)\.pm$/ unless $name;
        say "$cf\t$name";
        ($name) = $cf =~ /\/?([\w\.]+)$/ unless $name;
        say "not pm? $name";
        $name = $cf unless $name;
        say "nah \t\t\t\t\t\t\t$name";
        my $codon = $self->codon_by_name($name);
        my $isnew = 1 if !$codon;

        my $mtime = (stat $cf)[9];

            if ($isnew) {
                $codon = new Codon($self->hostinfo->intro, {
                    codefile => $cf,
                    name => $name,
                    mtime => $mtime,
                });
            }

        if ($codon->{mtime} < $mtime) {
            say "$cf changed";
            $codon->{mtime} = $mtime;
            $isnew = 1;
        }

            if ($isnew) {
                push @{ $self->{codes} }, $codon;
                say "new Codon: $codon->{name}\t\t".scalar(@{$codon->{lines}})." lines";
            }
    }
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
            return { top => 1, left => 1, horizontal => 40, wrap_at => 1200 } # space tabs by 40px
        },
    });

    $self->{codonmenu}->text->replace($self->{codes});
} # }}}

sub load_codon {
    my $self = shift;
    my $codon = shift;
    $codon = $self->codon_by_name($codon) unless ref $codon;
    say "Load Codon for $codon->{name}";
    die "Can't load Codon" unless $codon;

    $self->{the_codon} = $codon;
    $codon->{text} = $self->{codon}->text; # {codon} is a View
    $codon->display();
}

sub codon_by_name {
    my $self = shift;
    my $name = shift;
    my ($code) = grep { $_->{name} eq $name } @{ $self->{codes} };
    $code;
}



sub readfile {
    my $self = shift;
    my $path = shift;
    $path = $self->{code_dir}.$path if $self->{code_dir};
    read_file($path, @_);
}
sub writefile {
    my $self = shift;
    my $path = shift;
    $path = $self->{code_dir}.$path if $self->{code_dir};
    write_file($path, @_);
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
