package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;
use File::Slurp;
use Time::HiRes 'gettimeofday';

has 'hostinfo';
sub ddump { Hostinfo::ddump(@_) }
sub hi { shift->{hostinfo} }
has 'pid';
has 'kilt';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{avoid_app_menu} = 1;

    $self->{git} = shift;
    $self->{cmd} = shift;
    my $i = $self->{id};

    $self->{Proc} =
        $self->{git}->{Procshow}->spawn_floozy($self->{id},
            'width:92%; border: 2px dashed black; background: #005a50; color: #afc; font-weight: bold;');

    $self->{controls} =
        $self->{Proc}->spawn_ceiling("$self->{id}_controls",
            "font-size: 2em; font-family: serif; background-color: black; width: 99%; text-shadow: 4px 4px 4px #white; height: 1em; margin-bottom: 5px;");

    $self->{out} =
        $self->{Proc}->spawn_floozy("$self->{id}_out",
            "width: 100%; background-color: #000; border: 2px solid white; border: 3px solid gold; overflow: scroll; margin: 2px; padding: 5px;");
    $self->{in} =
        $self->{Proc}->spawn_floozy("$self->{id}_in",
            "width: 100%; background-color: #321; border: 2px solid white; border: 3px solid gold; overflow: scroll; margin: 2px;");

    $self->init();

    if ($self->{cmd}) {
        $self->start();
    }
    else {
        $self->{vacant} = 1;
    }
    return $self;
}

sub init {
    my $self = shift;

    $self->{out}->text->add_hooks({
        spatialise => sub { { left => 0, top => 0, space => 14 } },
        fit_div => 1,
    });
    $self->{out}->text->{max_height} = 420 * 1.1;

    $self->{in}->text->add_hooks({
        spatialise => sub { { left => 0, top => 0, space => 14 } },
        fit_div => 1,
    });
    $self->{in}->text->{max_height} = 420 * 0.34;


    my $ct = $self->{controls}->text;
    my $menu = $self->{the_controls} = {
        kp => sub {
            $self->kill();
        },
        kc => sub {
            $self->killc();
        },
        web => sub {
            $self->open_web_in_tab();
        },
        X => sub {
            $self->hi->send("\$('#$self->{Proc}->{divid}').remove();");
        },
    };
    $ct->add_hooks({
        style => sub {
            return 'font-size: 1em; '.random_colour_background();
        },
        spatialise => sub {
            return { top => 1, left => 1, horizontal => 40, wrap_at => 1200 } # space tabs by 40px
        },
        event => sub {
            my $texty = shift;
            my $event = shift;
            my $s = $texty->id_to_tuxt($event->{id});
            if (my $m = $s->{menu}) {
                $menu->{$m}->($event, $s);
            }
            else {
                say "Proc tuxt non handles click on $s->{value}";
            }
        },
        class => 'menu',
    });
    $self->{controls_lines} ||= [ "!style='color: #CCFF66;' $self->{pid}", "!menu web", "!menu kp", "!menu kc", '!menu X' ];
    $ct->replace($self->{controls_lines});
}


sub start {
    my $self = shift;
    say "$self->{id} starting $self->{cmd}";
    $self->{cmd}  =~ s/<<ID>>/$self->{id}/;

    my $cmd = $self->{cmd};
    $cmd =~ s/\n$//s;

    $self->output("Starting: $cmd");
    
    $cmd = "$$: $cmd\n";
    write_file("proc/start", {append => 1}, $cmd);
}

sub started {
    my $self = shift;
    my $pid = shift;
    $self->{pid} = $pid;

    $self->init();

    $self->output(qq{!html cmd: <span style="color: gold;">$self->{cmd}</span>}) if delete $self->{vacant};
    $self->output("$self->{id} ($pid)");
    unless ($self->is_running()) {
        $self->killed("uiet");
        $self->output("Proc: $self->{id} already dead");
        $self->hi->send("\$('#$self->{Proc}->{divid}').css('background-color', 'white');");
    }


    for my $ch (reverse "err", "out") { # TODO high speed proc output stitcher: read each handle, other signals it at 50Hz
        $self->hostinfo->stream_file("proc/$pid.$ch", sub {
            my $line = shift;
            $self->output($line, $ch);
        });
    }
}

sub output {
    my $self = shift;
    my $line = shift;
    my $ch = shift || 'non';
    my $stylech = {
        err => "color: #FF0066; text-shadow: 2px 2px 4px #3D001F;",
        out => "color: white; ",
        non => "color: #0066FF; font-weight: 500;",
        poo => "color: #FFDA91; ",
    };
    my $much = $ch =~ /err|out/ ? "out" : "in";
    my $t = $self->{$much}->text;
    $t->{hooks}->{tuxtstyle} = $stylech->{$ch};

    if ($ch eq "err" && $line =~ s/(\[info\] Listening at )"(.+)"\./$1<a href="$2">$2<\/a>/) {
        $self->{website} = $2;
        $line = "!html $line";
    }
    elsif ($ch eq "err" && $line =~ /(Can't create listen socket: Address already in use)/) {
        $self->bung(split ': ', $1);
    }
    elsif ($ch eq "out" && $line =~ /running (\w+) PID=(\d+) into /) {
        $self->{cpid} = $2;
        $self->output("Fished up $1 child pid: $2");
    }

    $t->append([$line]);
    
    say "Appent $self->{id} $self->{pid}>$ch: $line";
}

sub bung {
    my $self = shift;
    my @argh = @_;
    $self->hi->timer(0.5, sub { $self->output("IS BUNG: $_", "poo") for @argh });
}

sub open_web_in_tab {
    my $self = shift;
    return $self->output("No 'Listening at' printed yet") unless $self->{website};
    $self->hi->send("window.open('$self->{website}');");
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub event {
    my $self = shift;
    my $event = shift;
    my $id = $event->{id};
    my $ct = $self->{controls}->text;
    
    if (my $s = $ct->id_to_tuxt($id)) {
        my $it = $s->{value};
        $self->output("You wanna $it");
    }
}

sub killc {
    my $self = shift;
    my $cpid = $self->{cpid};
    if ($cpid) {
        $self->output("Killing underling $self->{cpid}");
        $self->kill($self->{cpid});
    }
    else {
        $self->output("There is no child pid");
    }
}

sub kill {
    my $self = shift;
    $self->{kill_pid} = $self->{pid} || shift || die "kill no pid";
    if ($_[0]) {
        $self->{kill_andthen} = shift;
    }

    if ($self->{killing}) {
        $self->{killing} = 0;
        $self->output("Killing stopped");
    }
    else {
        $self->{killing} = 1;
        $self->kill_loop();
    }
}

sub killed {
    my $self = shift;
    unless (shift) {
        $self->output("is gone.");
        $self->hi->timer(2, sub { $self->output("is gone."); });
        $self->hi->timer(1, sub { $self->output("is gone."); });
    }
    
    delete $self->{killing};
    delete $self->{kill_pid};
    $self->{gone} = 1;
}

sub is_running {
    my $self = shift;

    my $state = $self->{git}->init_state();
    exists $state->{ps}->{$self->{pid}}
}

sub kill_loop {
    my $self = shift;

    return unless $self->{killing};
    if (!$self->is_running) {
        $self->killed();
        return;
    }

    my $sig = $self->{killing}++ > 2 ? "KILL" : "INT";
    CORE::kill $sig, $self->{kill_pid};
    $self->output("kill $sig $self->{kill_pid}");

    $self->hi->timer(1, sub { $self->kill_loop });
}

1;
