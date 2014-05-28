package Git;
use strict;
use warnings;

sub hi { shift->{hostinfo} }

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hi->set("Git/repos", [ map { "style$_" } qw{ house shed bucky } ]);
    $self->wire_procs();

    my $G = $hi->{flood}->spawn_floozy($self, Git => "width:58%;  background: #352035; color: #afc; height: 4px; border: 2px solid light-blue;");
    $G->spawn_floozy($self, pswatch => "width:92%; background: #301a30; color: #afc; font-weight: bold; height: 2em;");
    $G->spawn_floozy($self, procwatch => "width:92%; height: 38em; border: 3px solid gold; background: #301a30; color: #afc; font-weight: bold; overflow: scroll;");

    $self->init_state();
    
    $self->init_proc_list();

    return $self;
}


sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};

    my $staty = $self->{codostate}->text;

    if ($s = $staty->id_to_tuxt($id)) {
        my ($pid, $cmd) = split ": ", $s->{value};
        $self->errl("killing $pid: $cmd");
        kill "TERM", $pid;
        $self->{hostinfo}->timer(0.2, sub {
            $self->init_state()
        });
    }
    else {
        return $self->hostinfo->error("Codo event 404 for $id", $event);
    }
}


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


sub pswatch {
    my $self = shift;

    $self->init_state();
    my $ps = $self->{state}->{ps};

    my $what = [ sort map { "$_->{i} $_->{pid}: $_->{cmd}" } values %$ps ];

    $_ =~ s/^\d+ // for @$what;

    $self->{pswatch}->flooz(join "\n", @$what); # Tractor should make this interactive
}

sub procwatch {
    my $self = shift;

    my $pl = $self->{procwatch};
    $pl->text->{hooks}->{fit_div} = 1;
    $pl->text->{max_height} = 160;
    $pl->text->replace(['!html <b> proc/list </b>']);

    my $per_line = sub {
        my $line = shift;
        $line =~ s/\n$//;
        return unless $line =~ /\S/;
        my ($pid, $cmd_echo) = $line =~ /^(\d+): (.+)\n?$/;
        
        my $proc;
        for my $p (@{ $self->{procs} }) {
            say " - have $p->{cmd}";
            if ($p->{cmd} eq $cmd_echo) {
                $proc = $p;
                last;
            }
        }

        my $stat;
        if ($proc) {
            if ($proc->{pid}) {
                $stat = "$proc->{id} running";
                if ($proc->{pid} ne $pid) {
                    $self->{hostinfo}->error("proc/list name suggests had proc, different pid", $proc, $line);
                }
            }
            else {
                $proc->started($pid);
                $stat = "$proc->{id} s t a r t e d"
            }
        }
        else {
            $stat = "unknown";
        }
        $stat = "!html <i>$stat</i>";

        $pl->text->append([$line, $stat]);
    };

    # watch the list of started files and their pids
    $self->{hostinfo}->stream_file("proc/list", $per_line);
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
        next unless /style/;
        if (/(\d+) (.+)$/sm) {
            ($ps->{$1} = {
                pid => $1,
                cmd => $2,
                i => $i++,
            })->{cmd} =~ s/\n$//;
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
                my ($name, $mess) = $self->childcmd($p->{cmd});
                if ($p->{name} && ($p->{name} ne $name || $p->{mess} ne $mess)) {
                    die "conflicter of the... $p->{cmd}\n'$p->{name}' ne '$name' || '$p->{mess}' ne '$mess'\n".anydump($s);
                }
                $p->{name} = $name;
                $p->{mess} = $mess;
            }
        }
    }
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
    die "proc tower $tower not directory" unless -d $proctower;

    if ($style eq $top) {
        for my $y (@rest) {
            my $unto = "../$y/proc";
            die "remote proc $unto is a directory" if -d $unto;
            my $lw = readlink $unto;
            die "remote proc $unto already wired to $lw instead of $tower" if $lw && $lw ne $tower;
            `ln -s $tower $unto` unless $lw;
        }
    }
    else {
        my $procto = readlink 'proc';
        die "procs not wired" unless $procto;
        die "proc already wired to $procto instead of $tower" if $procto && $procto ne $tower;
    }
}

1;
