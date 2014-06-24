package Git;
use strict;
use warnings;
use feature 'say';
use Scriptalicious;

sub hi { shift->{hostinfo} }
sub ddump { Hostinfo::ddump(@_) }
sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $repos = $self->hi->set("Git/repos", [ map { "style$_" } qw{ house shed bucky } ]);
    for my $r (@$repos) {
        $self->hi->set("Git/repos/$r", {});
    }
    $self->wire_procs();

  #  return $self if $self->hi->get('style') ne "stylehouse";

    my $G = $self->hi->{flood}->spawn_floozy($self, Git => "width:100%;  background: #352035; color: #aff;");
    $G->spawn_ceiling($self, gitrack => "width:98%; background: #2E0F00; color: #afc; font-weight: bold; margin:1em;", undef, undef, "menu");

    $self->gitrack();
    

    return $self;
}
sub init {
    my $self = shift; 
    
    unless ($self->{Gitshow}) {
        my $G = $self->{Git};
        my $PS = $G->spawn_floozy($self, Procshow => "width:96%; background: #301a30; color: #afc; font-weight: bold; padding-top: 3em;");
        $PS->text->replace(['!class=hear Procshow']);

        my $GS = $G->spawn_floozy($self, Gitshow => "width:96%; background: #301a30; color: #afc; font-weight: bold; padding-top: 3em;");
        $GS->text->replace(['!class=hear Gitshow']);

        $GS->spawn_floozy($self, proclistwatch =>
            "width:97%; height: 38em; border: 3px solid gold; background: #301a30; color: #afc; font-size: 8pt; overflow: scroll;");
        $GS->spawn_floozy($self, procstartwatch =>
            "width:97%; height: 38em; border: 3px solid gold; background: #301a30; color: #afc; font-size: 8pt; overflow: scroll;");
        $GS->spawn_floozy($self, pswatch =>
            "width:96%; background: #301a30; color: #afc; font-weight: bold; height: 2em;");
        $GS->spawn_floozy($self, repos =>
            "width:96%; background: #301a30; color: #afc; font-weight: bold; height: 2em;");
    }
    
    $self->gitrack();

    $self->pswatch();
    
    $self->proclistwatch();

    $self->procstartwatch();

    $self->repos();
}
sub gitrack {
    my $self = shift;
    
    $self->{rackmenu} = {
        ps => sub {
            $self->pswatch("once");
        },
        i => sub {
            $self->init();
        },
        sp => sub {
            $self->spawn_proc('cd ../styleshed && git pull house conty');
        },
        sG => sub {
            $self->spawn_proc('cd ../styleshed && git gui');
        },
        hp => sub {
            $self->spawn_proc('cd ../stylehouse && git pull shed conty');
        },
        hP => sub {
            $self->spawn_proc('cd ../stylehouse && git push');
        },
        hG => sub {
            $self->spawn_proc('cd ../stylehouse && git gui');
        },
        BR => sub {
            $self->{hostinfo}->info("Bucky rip");
            run('cd ../stylebucky && git reset --hard');
        },
        'rps' => sub {
            $self->reprocserv();
        },
    };
    my $rt = $self->{gitrack}->text;
    $rt->add_hooks({
        tuxtstyle => sub {
            my ($v, $s) = @_;
            $s->{style} .= 'opacity: 0.5; text-shadow: -2px -3px 3px #9999FF; padding: 4.20px; color: black; font-size: 2em; '.random_colour_background();
        },
        class => "menu",
        nospace => 1,
        allmenu => 1,
        event => { menu => $self->{rackmenu} },
    });
    my @items = sort keys %{$self->{rackmenu}};
    $rt->replace([ @items]);
}
sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}


sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    my $pst = $self->{pswatch}->text if $self->{pswatch};

    if ($pst && (my $s = $pst->id_to_tuxt($id))) {
        my ($pid, $cmd) = split ": ", $s->{value};
        say "KILLING $pid";
        kill "INT", $pid;
        $self->{hostinfo}->timer(0.2, sub {
            $self->pswatch("once")
        });
    }
    else {
        return $self->{hostinfo}->error("Errour! no $id", $event);
    }
}

sub reprocserv {
    my $self = shift;
    $self->spawn_proc('killall procserv.pl; ./procserv.pl &');
}

sub pstylecmd {
    my $self = shift;
    my $cmd = shift;

    if ($cmd && $cmd =~ /cd \.\.\/style(\S+) && echo '(.*)' && (?:perl |\.\/)stylehouse\.pl/) {
        return ($1, $2)
    }
}
sub mstylecmd {
    my $self = shift;
    my $name = shift;
    return "cd ../$name && ./stylehouse.pl"
}

sub spawn_style {
    my $self = shift;
    my $outside = shift;
    my $repo = $self->hi->get("Git/repos/$outside") || die "no such $outside";
    return $self->hi->error("../$outside does not exist") unless -d "../$outside";
    return $self->hi->error( "no procserv.pl") unless grep /procserv.pl/, `ps faux`;

        return $self->error("$outside already running") if $self->{state}->{$outside};

    my $P = $self->spawn_proc($self->mstylecmd($outside));
    $P->{repo} = $repo;
    $P
}

sub spawn_proc {
    my $self = shift;
    #$self->hi->info("spawning ".join", ",@_);
    my $cmd = shift;
    my $P = Proc->new($self->{hostinfo}->intro, $self, "echo '<<ID>>' && $cmd", @_);
    push @{$self->{procs}}, $P;
    $P
}
sub procup {
    my $self = shift;
    my ($pid, $cmd) = @_;
    say "$pid^$cmd";
    my $P = Proc->new($self->{hostinfo}->intro, $self);
    $P->{cmd} = $cmd;
    $P->started($pid);
    push @{$self->{procs}}, $P;
    $P
}

sub repos {
    my $self = shift;

    my $rt = $self->{repos}->text;
    $rt->{hooks}->{class} = "hidata";
    $rt->{hooks}->{fit_div} = 1;
    $rt->{max_height} = 400;

    my $menu = {
        up => sub {
            my ($e, $s) = @_;
            my $which = $s->{value};
            $self->spawn_style($which);
        },
    };
    $rt->add_hooks({
        spatialise => sub { { top => 1 } },
        event => sub {
            my $texty = shift;
            my $event = shift;
            my $s = $texty->id_to_tuxt($event->{id});
            if (my $m = $s->{menu}) {
                $menu->{$m}->($event, $s);
            }
            else {
                say "unhandled tuxt click: ".ddump($s);
            }
        },
    });

    my $repos = $self->hi->get('Git/repos');
    $rt->replace([ map { "!menu=up $_" } @$repos ]);
}

sub pswatch {
    my $self = shift;
    my $one = shift;

    $self->init_state();

    my $ps = $self->{state}->{ps};

    my $what = [ sort map { "$_->{i} $_->{pid}: $_->{cmd}" } values %$ps ];

    $_ =~ s/^\d+ // for @$what;

    my $pswt = $self->{pswatch}->text;
    $pswt->{hooks}->{fit_div} = 1;
    $pswt->{hooks}->{class} = "hidata";

    my @old = @{$pswt->{lines}};
    my $old = join "\n", @old;
    my $new = join "\n", @$what;
    if ($old =~ /\Q$new\E/) {
        #
    }
    else {
        $self->{pswatch}->text->replace([@$what]); # Tractor should make this interactive
    }

    $self->hi->timer(2, sub { $self->pswatch() }) unless $one;
}
sub procstartwatch {
    my $self = shift;

    my $plt = $self->{procstartwatch}->text;
    $plt->{hooks}->{fit_div} = 1;
    $plt->{hooks}->{class} = "hidata";
    $plt->{max_height} = 400;

    my $menu = {
        toggle => sub {
            $self->{procstartwatch}->{toggle}++;
            $self->procstartwatch();
        },
    };
    $plt->add_hooks({
        spatialise => sub { { top => 1, space => 10 } },
        event => sub {
            my $texty = shift;
            my $event = shift;
            my $s = $texty->id_to_tuxt($event->{id});
            if (my $m = $s->{menu}) {
                $menu->{$m}->($event, $s);
            }
            else {
                say "unhandled tuxt click: ".ddump($s);
            }
        },
    });

    my $hid = ($self->{prostartwatch}->{toggle} || 2) % 2;
    $plt->replace(["!menu=toggle !style='color: black; font-weight: bold;font-size: 10pt;  text-shadow: 2px 2px 4px #fa0;' proc/start".($hid ? " ~" : "")]);

    unless ($hid) {
        my $per_line = sub {
            my $line = shift;
            $line =~ s/\n$//;
            my ($pid, $cmd) = $line =~ /^(\d+): (.+)\n?$/;
            my $stat = $pid == $$ ? "!style='color:gold;' " : "";
            $plt->gotline("$stat$line");
        };

        $self->{hostinfo}->stream_file("proc/start", $per_line);
    }
}
sub proclistwatch {
    my $self = shift;

    my $plt = $self->{proclistwatch}->text;
    $plt->{hooks}->{fit_div} = 1;
    $plt->{hooks}->{class} = "hidata";
    $plt->{max_height} = 400;

    my $menu = {
        toggle => sub {
            $self->{proclistwatch}->{toggle}++;
            $self->proclistwatch();
        },
        startproc => sub {
            my ($e, $s) = @_;
            my ($pid, $cmd) = $s->{value} =~ /.+?(\d+): (.+)/;
            $self->procup($pid, $cmd);
        },
    };
    $plt->add_hooks({
        spatialise => sub { { top => 1, space => 10 } },
        event => sub {
            my $texty = shift;
            my $event = shift;
            my $s = $texty->id_to_tuxt($event->{id});

            if ($s->{menu}) {
                say "e t $s->{menu} ->";
                $menu->{$s->{menu}}->($event, $s);
            }
            else {
                say "Nothing for $s->{value}";
            }
        },
    });

    my $hid = ($self->{proclistwatch}->{toggle} || 2) % 2;
    $plt->replace([ "!menu=toggle !style='color: black; font-weight: bold; font-size: 10pt; text-shadow: 2px 2px 4px #fa0;' proc/list".($hid ? " ~" : "") ]);

    unless ($hid) {
        my $per_line = sub {
            my $line = shift;
            $line =~ s/\n$//;
            say "Line: $line";
            my ($pid, $cmd) = $line =~ /^(\d+): (.+)\n?$/;
            
            my %procs = map { $_->{cmd} => $_ } @{$self->{procs}};
            my $proc = $procs{$cmd};

            my $stat;
            if ($proc) {
                if ($proc->{pid}) {
                    $stat = "!style='color: green;'";

                    if ($proc->{pid} ne $pid) {
                        $self->{hostinfo}->error("proc/list Proc has Pid: $proc->{pid} vs $line");
                    }
                }
                else {
                    $proc->started($pid);
                    $stat = "!style='color: gold;'"
                }
            }
            else {
                $stat = "!menu=startproc";
            }

            $plt->append(["$stat $line"]);
        };

        # watch the list of started files and their pids
        $self->{hostinfo}->stream_file("proc/list", $per_line);
    }
}

sub init_state {
    my $self = shift;

    my $ch_p = {};
    for my $ch_f (glob('proc/*.*')) { #{{{
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
#}}}
    my $l_p = {};
    my $i = 0;
    for my $l (`cat proc/list`) { #{{{
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
# }}}
    my $ps = {};
    $i = 0;
    for (`ps -eo pid,cmd`) {
        next unless /style/ || /git/ || /procserv/;
        if (/(\d+) (.+)\n?$/sm) {
            $ps->{$1} = {
                pid => $1,
                cmd => $2,
                i => $i++,
            }
        }
    }

    my $s = $self->{state} ||= {};
    for my $w (qw{ch_p l_p l_p_i s_p_i ps}) {
        eval "\$s->{$w} = \$$w;";
        die $@ if $@;
    }

    for my $t (values %$s) {
        for my $p (values %$t) {
            if ($p->{cmd}) {
                my ($name, $mess) = $self->pstylecmd($p->{cmd});
                if ($p->{name} && ($p->{name} ne $name || $p->{mess} ne $mess)) {
                    die "conflicter of the... $p->{cmd}\n'$p->{name}' ne '$name' || '$p->{mess}' ne '$mess'\n".anydump($s);
                }
                $p->{name} = $name;
                $p->{mess} = $mess;
            }
        }
    }
    
    return $self->{state}
}


sub below {
    my $self = shift;

    my $next = sub {
        my $i = 0;
        for my $s (@{$_[0]}) {
            $i++;
            return $_[0]->[$i] if $s eq $_[1];
        }
        die "no such style: $_[1]\nhave: ".join" ",@{$_[0]};
    };
        
    my $repos = $self->hi->get('Git/repos');
    my $style = $self->{hostinfo}->get("style");
    my $unto = $next->($repos => $style);
    my $dir = "../$unto/";
    -d $dir || die "Cannot see $dir (am $style)";
    return $dir;
}

sub wire_procs {
    my $self = shift;
    my $repos = $self->hi->get('Git/repos');
    my ($top, @rest) = @$repos;
    my $style = $self->{hostinfo}->get("style");
    
    my $tower = "../$top/proc";
    die "proc tower $tower not exist"                                   unless -e $tower;
    die "proc tower $tower is a link somewhere else: ".readlink($tower) if -l $tower;
    die "proc tower $tower not directory" unless -d $tower;

    if ($style eq $top) {
        for my $y (@rest) {
            my $unto = "../$y/proc";
            if (-e $unto) {
                if (-l $unto) {
                    my $lw = readlink $unto;
                    if ($lw ne $tower) {
                        die "remote proc $unto already wired to $lw instead of $tower"
                    }
                    else { # sweet
                    }
                }
                else {
                    die "remote proc $unto is something else:\n".`ls -lh $unto`
                }
            }
            else {
                `ln -s $tower $unto`
            }
        }
    }
    else {
        if (-l 'proc') {
            my $procto = readlink 'proc';
            if ($procto ne $tower) {
                die "proc already wired to $procto instead of $tower"
            }
            else { # sweet
            }
        }
        else {
            die "procs not wired"
        }
    }
}

1;

