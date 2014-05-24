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
    my $codo_unto = {
        stylehouse => "styleshed",
        styleshed => "stylebucky",
    };
    if (my $unto = $codo_unto->{$style}) {
        my $dir = "../$unto/";
        -d $dir || die "Cannot see $dir (am $style)";
        $self->{code_dir} = $dir;
    }
    else { die "no such style: $style" }

    my $hi = $self->{hostinfo};
    

    my $cs =
    $hi->create_view($self, coshow => "width:58%;  background: #352035; color: #afc; height: 4px; border: 2px solid light-blue;");

        $cs->spawn_ceiling($self, codolist => "width:58%;  background: #402a35; color: #afc; height: 60px;");

        $cs->spawn_floozy($self, codostate => "width:92%;  background: #301a30; color: #afc; height: 60px; font-weight: bold;");

        $cs->spawn_floozy($self, processes => "width:92%;  background: #301a30; color: #afc; height: 60px; font-weight: bold;");


    $self->{obsetrav} = $hi->set("Codo/obsetrav", []); # observations of travel

    $self->init_codons();

    $self->codolist();

    $self->init_state();
    
    $self->init_proc_list();

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
            say "Sending view dump\n\n";
            $self->infrl("views", $self->hostinfo->dkeys);
        },
        "<obso>" => sub {
            say "Sending obsotrav dump\n\n";
            $self->infrl("obsetrav", split "\n", ddump($self->hostinfo->get("Codo/obsetrav")));
        },
        "RRR" => sub { # they might wanna load new css/js too
            $self->infrl('restarting (if)');
            `touch $0`;
        },
        "spawn" => sub {
            $self->spawn_child();
        },
        "restate" => sub {
            $self->init_state();
        },
    }
}

sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    my $listy = $self->{codolist}->text;
    my $staty = $self->{codostate}->text;

    say $self->{codolist}->{divid}." $id";

    if (my $s = $listy->id_to_tuxt($id)) {
        my $it = $s->{value};
        if ($s->{codon}) {
            $self->load_codon($s->{codon});
        }
        else {
            die $s;
        }
    }
    elsif ($s = $staty->id_to_tuxt($id)) {
        my ($pid, $cmd) = split ": ", $s->{value};
        $self->errl("killing $pid: $cmd");
        kill "INT", $pid;
        $self->{hostinfo}->timer(0.2, sub {
            $self->init_state()
        });
    }
    else {
        return $self->hostinfo->error("Codo event 404 for $id", $event);
    }
}

sub spawn_child {
    my $self = shift;
        return $self->errl( "no procserv.pl",
            "cannot spawn processes", "run ./procserv.pl yourself") unless grep /procserv.pl/, `ps faux`;
    my $outside = "styleshed";
        return $self->errl("$outside already running") if $self->{state}->{$outside};
        return $self->errl("../$outside does not exist") unless -d "../$outside";

    push @{$self->{procs}}, Proc->new($self->{hostinfo}->intro, $self->{processes}, $self->childcmd($outside))
}

sub init_proc_list {
    my $self = shift;

    my $pl = $self->{proc_list} = $self->{coshow}->spawn_floozy(
        'proc_list', "width:92%;  background: #303a3a; color: #afc; height: 60px; font-weight: bold;"
    );
    $pl->{extra_label} = "proc/list";

    # watch the list of started files and their pids
    $self->hostinfo->stream_file("proc/list", sub {
        my $line = shift;
        chomp $line;
        $self->{hostinfo}->snooze();

        $pl->text->append([$line]);
        
        return 0 unless $line =~ /\S/;

        my ($pid, $cmd_echo) = $line =~ /^(\d+): (.+)$/;
        my $proc;
        for my $p (@{ $self->{procs} }) {
            say " - have $p->{cmd}";
            if ($p->{cmd} eq $cmd_echo) {
                $proc = $p;
                last;
            }
        }

        if ($proc) {
            $pl->text->append(["!html <i>YUP</i>"]);
            say "\n proc appears $pid: $cmd_echo";
            #$proc->started($pid);
        }
        else {
            $pl->text->append(["!html <i>not ours</i>"]);
            say "\n proc not ours; $cmd_echo";
        }

        return 0;
    });
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



sub childcmd {
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

sub init_state { # {{{
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
        next unless $l =~ /\S/;
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
        if (/(\d+) (.+)$/sm) {
            ($ps->{$1} = {
                pid => $1,
                cmd => $2,
                i => $i++,
            })->{cmd} =~ s/\n$//;
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
                my ($name, $mess) = $self->childcmd($p->{cmd});
                if ($p->{name} && ($p->{name} ne $name || $p->{mess} ne $mess)) {
                    die "conflicter of the... $p->{cmd}\n'$p->{name}' ne '$name' || '$p->{mess}' ne '$mess'\n".anydump($s);
                }
                $p->{name} = $name;
                $p->{mess} = $mess;
            }
        }
    }
#}}}


    my $what = [
        sort map { "$_->{i} $_->{pid}: $_->{cmd}" } values %$ps ];
    $_ =~ s/^\d+ // for @$what;
    $self->{codostate}->flooz(join "\n", @$what); # Tractor should make this interactive
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
