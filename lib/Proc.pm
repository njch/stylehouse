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
            "font-size: 2em; font-family: serif; background-color: black; width: 99%; text-shadow: 4px 4px 4px #white; height: 2em;");

    $self->{out} =
        $self->{Proc}->spawn_floozy("$self->{id}_out",
            "left: -5px; width: 110%; background-color: #111; border: 2px solid white; overflow: scroll; margin: 1em;");

    $self->init();

    if ($self->{cmd}) {
        $self->start();
    }
    else {
        $self->output("Vacant lot");
        say "Proc vacant lot";
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

    my $ct = $self->{controls}->text;
    my $menu = {
        kill => sub {
            $self->kill();
        },
        web => sub {
            $self->open_web_in_tab();
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
                $self->hi->error("unhandled tuxt click in controls", $s, $self);
            }
        },
        class => 'menu',
    });
    $ct->replace([ "!menu web", "!menu=kill kill($self->{pid})" ]);

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
    $self->output("Picked up: $self->{cmd}") if delete $self->{vacant};
    $self->output("Proc: $self->{id} started ($pid)");

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
    my $ot = $self->{out}->text;
    $ot->{hooks}->{tuxtstyle} = $stylech->{$ch};

    if ($ch eq "err" && $line =~ s/(\[info\] Listening at )"(.+)"\./$1<a href="$2">$2<\/a>/) {
        $self->{website} = $2;
        $line = "!html $line";
    }
    elsif ($ch eq "err" && $line =~ /(Can't create listen socket: Address already in use)/) {
        $self->bung(split ': ', $1);
    }

    $ot->append([$line]);
    
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
        say "You wanna $it";
        $self->{mess}->text->append(['You wanna $it']);
    }
}

sub kill {
    my $self = shift;
    if ($_[0]) {
        $self->{kill_andthen} = shift;
    }
    $self->{pid} || die "kill no pid";

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
    $self->output("Killed");
    delete $self->{killing};
    $self->{killed} = 1;
}

sub kill_loop {
    my $self = shift;

    return unless $self->{killing};

    my $state = $self->{git}->init_state();
    if (!exists $state->{ps}->{$self->{pid}}) {
        $self->killed();
        return;
    }

    my $sig = $self->{killing}++ > 2 ? "KILL" : "INT";
    kill $sig, $self->{pid};
    $self->output("kill $sig $self->{pid}");

    $self->hi->timer(1, sub { $self->kill_loop });
}

1;
