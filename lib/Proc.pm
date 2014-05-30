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
has 'output';
has 'pid';
has 'kilt';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{avoid_app_menu} = 1;

    $self->{flwhere} = shift;
    $self->{cmd} = shift;
    my $i = $self->{id};


    $self->{Proc} =
        $self->{flwhere}->spawn_floozy($self->{id},
            'width:92%; border: 2px dashed black; background: #005a50; color: #afc; font-weight: bold;');

    say "$self->{Proc} is!";
    $self->{controls} =
        $self->{Proc}->spawn_ceiling("$self->{id}_controls",
            "background-color: black; width: 99%; text-shadow: 4px 4px 4px #white; height: 2em;");

    my $ct = $self->{controls}->text;
    $ct->add_hooks({
        tuxtstyle => sub {
            return 'font-size: 1em; '.random_colour_background();
        },
        spatialise => sub {
            return { top => 1, left => 1, horizontal => 20, wrap_at => 1200 } # space tabs by 40px
        },
        class => 'menu',
    });
    $ct->replace([ "KILL", "web" ]);

    $self->{mess} =
        $self->{Proc}->spawn_floozy("$self->{id}_mess",
            "background: #353; width: 99%; border: 2px solid black; text-shadow: 4px 4px 4px #white; margin: 1em;");
    $self->{mess}->text->{hooks}->{fit_div} = 1;

    if ($self->{cmd}) {
        $self->start();
    }
    else {
        $self->{mess}->text->append(['Vacant lot']);
        say "Proc vacant lot";
        $self->{vacant} = 1;
    }


    return $self;
}
sub start {
    my $self = shift;
    say "$self->{id} starting $self->{cmd}";
    $self->{cmd}  =~ s/<<ID>>/$self->{id}/;

    my $cmd = $self->{cmd};
    $cmd =~ s/\n$//s;

    $self->{mess}->text->append(["$cmd"]);
    
    $cmd = "$$: $cmd\n";
    write_file("proc/start", {append => 1}, $cmd);
}

sub started {
    my $self = shift;
    my $pid = shift;
    $self->{pid} = $pid;

    my @mesa;
    push @mesa, "Picked up: $self->{cmd}" if $self->{vacant};
    push @mesa, "Proc: $self->{id} started ($pid)";
    $self->{mess}->text->append([@mesa]);
    say $_ for @mesa;

    my $opc = $self->{Proc}->spawn_floozy("$self->{id}_opc",
        "width: 99%; background-color: #111; border: 2px solid white; overflow: scroll; margin: 1em;");

    $opc->text->add_hooks({
        spatialise => sub { { left => 0, top => 0 } },
        fit_div => 1,
    });
    $opc->text->{max_height} = 420 * 1.1;
    my $opc_ch = {
        err => "color: #FF0066; text-shadow: 2px 2px 4px #3D001F;",
        out => "color: white; ",
    };
    for my $d ("err", "out") {
        $self->hostinfo->stream_file("proc/$pid.$d", sub {
            my $line = shift;
            say "Got Line from $pid $d: $line";
            $opc->text->{hooks}->{tuxtstyle} = $opc_ch->{$d};
            $opc->text->append([$line]);
        });
    }

}
sub init {
    my $self = shift;
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

# talk to procserv (at the end in ``), setup handlers for its output
sub kill {
    my $self = shift;
    $self->{pid}
        || return say "! ! ->nah before Proc got pid ! !";

    kill "INT", $self->{pid};

    $self->killed();
}
sub killed {
    my $self = shift;
    $self->{killed}++; # tell whatever somehow (later)
}

1;
