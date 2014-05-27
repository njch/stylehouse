package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;
use File::Slurp;
use Time::HiRes 'gettimeofday';

has 'hostinfo';
has 'output';
has 'pid';
has 'kilt';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->{avoid_app_menu} = 1;

    my $play_in = shift;
    $self->{play} = $play_in->spawn_floozy($self->{id},
                                    'width:92%; border: 2px dashed black; background: #005a50; color: #afc; font-weight: bold;');

    $self->{controls} = $self->{play}->spawn_ceiling("$self->{id}_controls",
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


    $self->{mess} = $self->{play}->spawn_ceiling("$self->{id}_mess",
                                    "background: #353; width: 89%; border: 2px solid black; text-shadow: 4px 4px 4px #white;");
    $self->{mess}->text->{hooks}->{fit_div} = 1;

    $self->{cmd} = shift;
    if ($self->{cmd}) {
        $self->{cmd}  =~ s/<<ID>>/$self->{id}/;

        my $cmd = $self->{cmd};
        $cmd =~ s/\n$//s;

        $self->{mess}->text->append(["$cmd"]);
        
        $cmd = "$$: $cmd\n";
        write_file("proc/start", {append => 1}, $cmd);
    }
    else {
        $self->{mess}->text->append(['Vacant lot']);
        say "Proc vacant lot";
    }


    return $self;
}

sub random_colour_background {
    my ($rgb) = join", ", map int rand 255, 1 .. 3;
    return "background: rgb($rgb);";
}

sub started {
    my $self = shift;
    my $pid = shift;
    $self->{pid} = $pid;

    say "Proc: $self->{id} started ($pid)";

    my $opc = $self->{play}->spawn_floozy("$self->{id}_opc", "width: 99%; background-color: #444; border: 2px solid white;");
    $opc->text->{hooks}->{spatialise} = sub { { left => 0, top => 0 } };
    my $opc_ch = {
        err => "color: pink; text-shadow: 2px 2px 4px #000;",
        out => "color: white; ",
    };
    for my $d ("err", "out") {
        $self->hostinfo->stream_file("proc/$pid.$d", sub {
            my $line = shift;
            $opc->text->{hooks}->{tuxtstyle} = $opc_ch->{$d};
            $opc->text->append([$line]);
        });
    }

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

sub event {
    my $self = shift;
}

1;
