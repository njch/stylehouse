package Git;
use strict;
use warnings;
use feature 'say';
use Scriptalicious;
use File::Slurp;
use utf8;

our $H;
sub ddump { Hostinfo::ddump(@_) }
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->wire_procs();

    my $G = $H->{flood}->spawn_floozy($self, Git => "width:100%;  background: #352035; color: #aff;");
    $G->spawn_ceiling($self, gitrack => "width:98%; background: #2E0F00; color: #afc; font-weight: bold; margin:1em;", undef, undef, "menu");

    $self->gitrack();

    return $self;
}
sub gitrack {
    my $self = shift;
    
    my $ps = sub {
        my $cmd = shift;
        $cmd = "$$: $cmd\n";
        write_file("proc/start", {append => 1}, $cmd);
    };
    
    my @m;
    for my $r ('styleshed') {
        my $menu = [
    '⏚' => sub {
        say" HEading to $r";
        $ps->("cd ../$r && git gui");
    },
    'ⵘ' => sub {
        my @hmm = grep /stylehouse\.pl/, `ps faux | grep stylehouse`;
        my @har = split /\s+/, pop @hmm;
        `kill -KILL $har[1]`;
    },
    '᎒' => sub {
        my @hmm = grep /S\.pm/, `ps faux | grep perl.l/S.p`;
        my @har = split /\s+/, pop @hmm;
        `kill -KILL $har[1]`;
    },
    'ܤ' => sub {
        `touch /s/stylehouse.pl`
    },
    'r' => sub {
        `touch /s/l/S.pm`
    },
        ];
        push @m,
        { _spawn => [ [], {
        nospace => 1,
        event => { menu => $menu },
        class => 'menu en',
        }],
        S_attr => { style => "font-size:36pt;"},
        };
    }
    my $rt = $self->{gitrack}->text([@m], {
        tuxtstyle => sub {
            my ($v, $s) = @_;
            $s->{style} .= 'opacity: 0.5; text-shadow: -2px -3px 3px #9999FF; padding: 4.20px; color: black; font-size: 2em; '.random_colour_background();
        },
        class => "menu",
        nospace => 1,
    });
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
        $H->timer(0.2, sub {
            $self->pswatch("once")
        });
    }
    else {
        return $H->error("Errour! no $id", $event);
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
    my $repo = $H->get("Git/repos/$outside") || die "no such $outside";
    return $H->error("../$outside does not exist") unless -d "../$outside";
    return $H->error( "no procserv.pl") unless grep /procserv.pl/, `ps faux`;

        return $self->error("$outside already running") if $self->{state}->{$outside};

    my $P = $self->spawn_proc($self->mstylecmd($outside));
    $P->{repo} = $repo;
    $P
}
sub spawn_proc {
    my $self = shift;
    #$H->info("spawning ".join", ",@_);
    my $cmd = shift;
    my $P = Proc->new($H->intro, $self, "echo '<<ID>>' && $cmd", @_);
    push @{$self->{procs}}, $P;
    $P
}
sub procup {
    my $self = shift;
    my ($pid, $cmd) = @_;
    say "$pid^$cmd";
    my $P = Proc->new($H->intro, $self);
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

    my $repos = $H->get('Git/repos');
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

    $H->timer(2, sub { $self->pswatch() }) unless $one;
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

        $H->stream_file("proc/start", $per_line);
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
                        $H->error("proc/list Proc has Pid: $proc->{pid} vs $line");
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
        $H->stream_file("proc/list", $per_line);
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
sub rbe {
    my $self = shift;
    my $side = shift;
    my $s = shift || $H->get("style");
    if ($s =~ /stylehut/) {
        return "/s/";
    }
    
    my ($l, $r);
    my @rs = @{ $H->get('Git/repos') };
    while (my $c = shift @rs) {
        $r = $rs[0];
        if ($s eq $c) {
            if ($side && $side eq "up") {
                return $l;
            }
            else {
                return $r;
            }
        }
        $l = $c;
    }
    die "NO WTF";
}
sub wire_procs {
    my $self = shift;
    my $tower = "/h/proc";
    die "proc tower $tower not exist"                                   unless -e $tower;
    die "proc tower $tower is a link somewhere else: ".readlink($tower) if -l $tower;
    die "proc tower $tower not directory" unless -d $tower;
}

1;

