package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use YAML::Syck;
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
    $hi->create_view($self, Codo => "width:58%; min-width: 600px; background: #f7772e; color: #afc; position: absolute; top: $self->{hostinfo}->{horizon}; right: 0px; z-index:4; opacity: 0.95;");

    $Codo->spawn_ceiling($self, 'codseal' => 'border: 1px solid beige;')
        ->spawn_floozy($self, codolist =>
            "width:500px; z-index:3; background: #402a35; color: #afc; opacity: 1; hegith: 8em;");


        $Codo->spawn_floozy($self, blabs => "width:92%;  background: #301a30; color: #afc; font-weight: bold; height: 2em;");



    $self->{obsetrav} = $hi->set("Codo/obsetrav", []); # observations of travel

    $self->init_codons();

    $self->codolist();
    $self->{codolist}->float();

    my $ao = $self->{all_open} = [];
    $self->re_openness();

    $self->load_codon("Lyrico") unless @$ao;

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
    else {
        $self->{hostinfo}->error("Codo event 404 for $id". ddump($event));
    }
}

sub init_codons {
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
                    codo => $self,
                });
            }

        if ($codon->{mtime} < $mtime) {
            say "$cf changed";
            $codon->{mtime} = $mtime;
            $isnew = 1;
        }
    }
}


sub codolist {
    my $self = shift;

    my $codons = $self->{hostinfo}->get("Codon");
    die "no codons" unless $codons;
    say "Codons number ".@$codons;
    my $list = $self->{codolist};
    my $listy = $list->text;
    
    my $menu = {
        h => sub {
            my ($ev, $s) = @_;
            if ($s->{codon}) {
                $self->load_codon($s->{codon});
            }
            else {
                $self->{hostinfo}->error(" no go diggy die", $ev, $s);
            }
        },
        float => sub {
            $list->float();
        },
        _ => sub {
            $_->away for @{ $self->{all_open} };
        },
        S => sub {
            $_->save_all for @{ $self->{all_open} };
        },
    };
    $listy->add_hooks({
        tuxts_to_htmls_tuxt => sub {
            my ($texty, $s) = @_;

            if (ref $s->{value} eq "Codon") {
                my $codon = $s->{value};
                $s->{value} = $codon->{name};
                $s->{value} =~ s/^ghosts\///;
                $s->{codon} = $codon;
                $s->{style} .= 'background-color: #'.codoncolour($codon).';'
                    .($codon->{name} =~ /^ghosts\// ? 'color: #5A5AAF;' : '');
                $s->{menu} = "h";
            }
            elsif ($s->{menu}) {
                $s->{style} .= "border: 2px solid #8A002E"
            }
        },
        nospace => 1,
        class => 'menu',
        tuxtstyle => "opacity: 0.9; font-size: 17pt; padding-bottom: 2px; color: #99FF66; font-weight: 700;"
            ."text-shadow: 2px 4px 5px #4C0000;",
        event => { menu => $menu },
    });

    my $lines = [ map { "!menu $_" } keys %$menu ];
    my $coname = { map { $_->{name} => $_ } @$codons };
    for my $n (qw'stylehouse.pl stylehouse.js stylehouse.css',
               qw'Codo Codon Direction',
               qw'Travel Ghost Wormhole Lyrico Texty View') {

        push @$lines, delete $coname->{$n};
    }
    push @$lines, values $coname;
    $listy->replace($lines);
}

sub codoncolour {
    my $codon = shift;
    my $n = $codon->{name};

    $n =~ /^ghost/ ? "99FF66" :
    $n =~ /Travel|Ghost|Wormhole/ ? "990906" :
    $n =~ /Texty/ ? "00FFFF" :
    $n =~ /View|Lyrico/ ? "CCFF66" :
    $n =~ /Hostinfo/ ? "3366FF" :
    $n =~ /Codo/ ? "3366FF" :
    $n =~ /Codon/ ? "3366FF" :
    $n =~ /stylehouse/ ? "00CCFF" :
    $n =~ /stylehouse\.pl/ ? "33CDDD" :
    $n =~ /Codon/ ? "3366FF" :
    "B8B86E"
}

sub re_openness {
    my $self = shift;

    my $codopenyl = "Codo-openness.yml";
    my $open = LoadFile($codopenyl) if -e $codopenyl;
    for my $o (@$open) {
        my ($name, $ope) = @$o;
        while (my ($k, $v) = each %$ope) {
            if ($v eq "Open") {
                $ope->{$k} = 'Opening';
            }
        }
        say "Ressur $name";
        $self->load_codon($name, $ope);
    }
}

sub mind_openness {
    my $self = shift;
    my $codon = shift;

    if ($codon) {
        my $codlt = $self->{codolist}->{text};
        my ($menut) = grep { $_->{codon} && $_->{codon} eq $codon } @{ $codlt->{tuxts} };
        if ($menut) {
            $self->{hostinfo}->send(
                "\$('#$menut->{id}').addClass('onn');"
            );
        }
        else {
            $self->{hostinfo}->error("No findo $codon->{name} in codolist");
        }
    }

    if ($codon && !grep { $_ eq $codon } @{$self->{all_open}}) {
        say "Codon minded: $codon->{name}";
        push @{$self->{all_open}}, $codon;
    }

    my @saveopen = map {
        [ $_->{name} => $_->{openness} ]
    } grep { defined $_ } @{$self->{all_open}};

    DumpFile("Codo-openness.yml", \@saveopen);
}

sub lobo {
    my $self = shift;
    my $codon = shift;
    
    @{$self->{all_open}} =
        grep { $_ ne $codon } @{$self->{all_open}};
    
    my $codlt = $self->{codolist}->{text};
    my ($menut) = grep { $_->{codon} eq $codon } @{ $codlt->{tuxts} };
    if ($menut) {
      $self->{hostinfo}->send(
          "\$('#$menut->{id}').removeClass('onn');"
      );
    }
    else {
        $self->{hostinfo}->error("No findo $codon->{name} in codolist");
    }
}

sub list_of_codefiles {
    my $self = shift;
    my $dir = $self->{code_dir} || "";
    die "$dir not dir" unless -d $dir;
    $dir .= "/" unless $dir =~ /\/$/;
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
    my $ope = shift;


    $codon = $self->codon_by_name($codon) unless ref $codon;
    say "Codo load $codon->{name}";
    $codon || die;
    
    say "OPen Codons: ".join", ", map { $_->{name} } @{$self->{all_open}};
    unless (grep { $_ eq $codon } @{$self->{all_open}}) {
        $codon->display($self, $ope);
        $self->mind_openness($codon);
    }
    $self->{hostinfo}->send(
    "\$.scrollTo(\$('#$codon->{show}->{divid}').offset().top, 360);"
    );
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
