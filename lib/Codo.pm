package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Codon;
use Proc;
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

    $self->{git} = $self->{hostinfo}->getapp("Git");
    $self->{code_dir} = $self->{git}->below(); 

    my $hi = $self->{hostinfo};
    

    my $Codo =
    $hi->create_view($self, Codo => "width:58%;  background: #f7772e; color: #afc; position: absolute; top: 50%; right: 0px; z-index:-1;");

        $Codo->spawn_ceiling($self, codolist => "width:98%;  background: #402a35; color: #afc; height: 60px;");


        $Codo->spawn_floozy($self, blabs => "width:92%;  background: #301a30; color: #afc; font-weight: bold; height: 2em;");



    $self->{obsetrav} = $hi->set("Codo/obsetrav", []); # observations of travel

    $self->init_codons();

    $self->codolist();

# recover openness 
    for my $s (@{$self->{codolist}->{text}->{tuxts}}) {
        $s->{value} eq "Ghost" && do {
            $self->event({id => $s->{id}});
        };
    }

    return $self;
}

sub menu {
    my $self = shift;
    $self->{menu} ||= {
        nah => sub { $self->nah },
        new => sub { $self->new_ebuge() },
        '<views>' => sub {
            $self->infrl("views", $self->hostinfo->dkeys);
        },
        "<obso>" => sub {
            $self->infrl("obsetrav", split "\n", ddump($self->hostinfo->get("Codo/obsetrav")));
        },
        "Rst" => sub { # they might wanna load new css/js too
            $self->infrl('restarting (if)');
            `touch $0`;
        },
        'MH' => sub {
            my $h = $self->{hostinfo};
            $h->{MH} = !$h->{MH};
            $self->infrl(map { $h->{MH} ? uc($_) : lc($_)." off" } 'MULTIHEADING');
        },
        '^>' => sub {
            $self->{hostinfo}->send("\$('#Codo').toggleClass('NE');");
        },
    }
}

sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    if ($id eq "codolist") {
        $self->{hostinfo}->send("\$('#".$self->{Codo}->{divid}."').toggleClass('widdle');");
    }

    my $listy = $self->{codolist}->text;

    say $self->{codolist}->{divid}." $id";

    if (my $s = $listy->id_to_tuxt($id)) {
        my $it = $s->{value};
        if ($it eq "Save") {
            $self->infrl("Argh! just do it yourself")
        }
        elsif ($s->{codon}) {
            $self->load_codon($s->{codon});
        }
        else {
            die $s;
        }
    }
    else {
        say "Codo event 404 for $id". ddump($event);
    }
}

sub init_codons { #{{{
    my $self = shift;

    say "\tI N I T   C O D ON S !";
    my @codefiles = $self->list_of_codefiles();

    for my $cf (@codefiles) {
        my $filename = $self->{code_dir}.$cf;
        my $name;
        ($name) = $cf =~ /\/?((?:ghosts|wormholes)\/\w+\/.+)$/ unless $name;
        ($name) = $cf =~ /\/?(\w+)\.pm$/ unless $name;
        ($name) = $cf =~ /\/?([\w\.]+)$/ unless $name;
        $name = $cf unless $name;
        my $codon = $self->codon_by_name($name);
        my $isnew = 1 if !$codon;

        my $mtime = (stat $filename)[9];

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
    }
}#}}}

sub codolist {#{{{
    my $self = shift;

    my $codons = $self->{hostinfo}->get("Codon");
    say "Codons number ".@$codons;

    my $codolistex = $self->{codolist}->text;
    $codolistex->add_hooks({
        tuxts_to_htmls => sub {
            my $self = shift;
            for my $s (@{$self->tuxts}) {
                if (ref $s->{value}) {
                    my $codon = $s->{value};
                    $s->{value} = $codon->{name};
                    $s->{codon} = $codon;
                }
                $s->{style} = random_colour_background();
                $s->{class} = 'menu';
            }
        },
        spatialise => sub {
            return { top => 1, left => 1, horizontal => 40, wrap_at => 1200 } # space tabs by 40px
        },
    });

    my $menu = [
        "Save",
        @$codons,
    ];
    $codolistex->replace($menu);
}#}}}


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

sub load_codon {
    my $self = shift;
    my $codon = shift;

    say "Codo load $codon->{name}";
    $codon = $self->codon_by_name($codon) unless ref $codon;
    $codon || die;

    $codon->display($self);
}

sub codon_by_name {
    my $self = shift;
    my $name = shift;
    
    if (my $codons = $self->{hostinfo}->get('Codon')) {
        for my $c (@$codons) {
            return $c if $c->{name} eq $name;
        }
    }
    return;
}

sub readfile {
    my $self = shift;
    my $path = shift;
    read_file($self->{code_dir}.$path, @_);
}
sub writefile {
    my $self = shift;
    my $path = shift;
    write_file($self->{code_dir}.$path, @_);
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub infrl {
    my $self = shift;
    my $first = shift;
    $first = qq{!html <h2>$first</h2>};
    $self->{hostinfo}->info(join "\n", $first, @_);
}
sub errl {
    my $self = shift;
    my $first = shift;
    $first = qq{!html <h2 class="err">$first</h2>};
    $self->{hostinfo}->error(join "\n", $first, @_);
}
sub proc_killed {
    my $self = shift;
    my $proc = shift;
    delete $self->{$proc->{name}};
    $self->{codostate}->text->replace(["!html <h4>styleshed killed</h4>"]);
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
