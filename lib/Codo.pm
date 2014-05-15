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

    my $style = $self->{hostinfo}->get("style");
    if ($style eq "stylehouse" && -e "../styleshed") {
        $self->{code_dir} = "../styleshed/"; # default .
    }

    my $hi = $self->{hostinfo};
    $hi->make_flooz($self, codostate => "width:58%;  background: #301a30; color: #afc; height: 60px; font-weight: bold;");
    
    $hi->make_view($self, codonmenu => "width:58%;  background: #402a35; color: #afc; height: 60px;");

    $hi->make_view($self, codon     => "width:58%;  background: #352035; color: #afc; height: 4px; border: 2px solid light-blue;");


    $self->{obsetrav} = $hi->set("Codo/obsetrav", []); # observations of travel

    $self->{codes} = $hi->get("Codo/codes")
                  || $hi->set("Codo/codes", []);

    $self->init_codons();

    $self->init_codemenu();

    $self->init_state();

    return $self;
}

sub menu {
    my $self = shift;
    $self->{menu} ||= do {
        my $m = {};
        $m->{"nah"} = sub { $self->nah };
        $m->{"new"} = sub { $self->new_ebuge() };
        $m->{"<views>"} = sub {
            say "Sending view dump\n\n";
            $self->infrl("views", $self->hostinfo->dkeys);
        };
        $m->{"<obso>"} = sub {
            say "Sending obsotrav dump\n\n";
            $self->infrl("obsetrav", split "\n", ddump($self->hostinfo->get("Codo/obsetrav")));
        };
        $m->{"RRR"} = sub { # they might wanna load new css/js too
            $self->infrl('restarting (if)');
            `touch $0`;
        };
        $m->{"spawn"} = sub {
            $self->spawn_child();
        };
        $m->{"restate"} = sub {
            $self->init_state();
        };

        $m;
    };
}

sub child {
    my $self = shift;
    my $given = shift;
    if ($given && $given =~ /^style(\w+)$/) {
        return "cd ../$given && echo '<<ID>>' && ./stylehouse.pl"
    }
    elsif ($given && $given =~ /cd \.\.\/style(\S+) && echo '(.*)' && (?:perl |\.\/)stylehouse\.pl/) {
        return ($1, $2)
    }
    else {
        return undef
    }
}

sub init_state {
    my $self = shift;

    my $ch_p = {};

    for my $ch_f (glob('proc/*.*')) {
        if ($ch_f =~ /(\d+)\.(\w+)/) {
            $ch_p->{$1} = {
                $2 => $ch_f,
                pid => $1,
            };
        }
        else {
            say "garbage from proc/*.*: $ch_f";
        }

    }

    my $l_p = {};

    my $i = 0;
    for my $l (`cat proc/list`) {
        if ($l =~ /(\d+): (.+)/) {
            $l_p->{$1} = {
                pid => $1,
                cmd => $2,
                i => $i++,
            };
        }
        else {
            say "garbage from proc/list: $l";
        }
    }

    my $l_p_i = {};
    for my $p (values %$l_p) {
        $l_p_i->{$p->{i}} = $p;
    }

    my $s_p_i = {};

    $i = 0;
    for my $s (`cat proc/start`) {
        my ($exec) = $s =~ /^(.+)/;
        $s_p_i->{$i} = {
            cmd => $exec,
            i => $i++,
        };
        
    }

    my $ps = {};

    $i = 0;
    for (`ps -eo pid,cmd | grep style`) {
        if (/(\d+) (.+)$/s) {
            $ps->{$1} = {
                pid => $1,
                cmd => $2,
                i => $i++,
            };
        }
    }

    my $s = $self->{state};
    for my $w (qw{ch_p l_p l_p_i s_p_i ps}) {
        eval "\$s->{$w} = \$$w;";
        die $@ if $@;
    }

    for my $t (values %$s) {
        for my $p (values %$t) {
            if ($p->{cmd}) {
                my ($name, $mess) = $self->child($p->{cmd});
                if ($p->{name} && ($p->{name} ne $name || $p->{mess} ne $mess)) {
                    die "conflicter of the... $p->{cmd}\n'$p->{name}' ne '$name' || '$p->{mess}' ne '$mess'\n".anydump($s);
                }
                $p->{name} = $name;
                $p->{mess} = $mess;
            }
        }
    }




    $self->{codostate}->flooz($s);
    say "Thy state:\n".anydump($s);
    my @style;

    if (0) {
    for my $p (@style) {
        $p->{_tuxtform} = sub {
            my ($p, $tuxt) = @_;
            $tuxt->{htmlval} = 1;
            say "proc form: ".ddump($p);
            my $chs = join " <br/>", map { '<span style="color: #230;">'.((-s $p->{$_}).' '.$_).'</span>' } qw{in err out};
            $p->{value} = '<span style="color: black;">'.$p->{pid}.'</span> '
                .'<span style="color: blue; left: 40px;"> '.($p->{name}||"???").'</span><br/>'
                .$chs;
            say "Proc value is: ".$p->{value};
        };
    }
    unless (@style) {   
        push @style, '!html <h2 style="color: black;"> nothin in proc/list </h2>';
    }
    my $cst = $self->{codostate_proc}->text;
    $cst->{hooks}->{spatialise} = sub { { horizontal => 166, top=> '5', left => '5' } };
    $cst->{hooks}->{tuxtstyle} = random_colour_background().' width:180px; height: 66px;';
    $cst->replace([@style]);
    }
}

sub spawn_child {
    my $self = shift;
    unless ( grep /procserv.pl/, `ps faux` ) {
        return $self->errl( "no procserv.pl",
            "cannot spawn processes", "run ./procserv.pl yourself");
    }
    my $outside = "styleshed";
    if ($self->{state}->{$outside}) {
        return $self->errl("$outside already running");
    }
    unless (-d "../$outside") {
        return $self->errl("../$outside does not exist");
    }
    $self->{outside} = Proc->new($self->{hostinfo}->intro, outside => $self->child($outside));
    $self->{outside}->{owner} = $self;
    $self->infrl("spawning $outside");
    $self->{hostinfo}->update_app_menu();
}
sub infrl {
    my $self = shift;
    my $first = shift;
    $first = qq{!html <h2>$first</h2>};
    $self->{hostinfo}->flood(join "\n", $first, @_);
}
sub errl {
    my $self = shift;
    my $first = shift;
    $first = qq{!html <h2 class="err">$first</h2>};
    $self->{hostinfo}->flood(join "\n", $first, @_);
}
sub proc_killed {
    my $self = shift;
    my $proc = shift;
    delete $self->{$proc->{name}};
    $self->{codostate}->text->replace(["!html <h4>styleshed killed</h4>"]);
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

# Codo-View-fc6272d1-Codo-Texty-c417836b-0 -> flood proc/ps/whatever data

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
sub init_codons {
    my $self = shift;

    say "INIT CODONS!";
    my @codefiles = $self->list_of_codefiles();

    for my $cf (@codefiles) {
        my $name;
        ($name) = $cf =~ /\/?((?:ghosts|wormholes)\/\w+\/.+)$/ unless $name;
        ($name) = $cf =~ /\/?(\w+)\.pm$/ unless $name;
        ($name) = $cf =~ /\/?([\w\.]+)$/ unless $name;
        $name = $cf unless $name;
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
                #say "new Codon: $codon->{name}\t\t".scalar(@{$codon->{lines}})." lines";
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
}

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
