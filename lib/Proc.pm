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
    $self->{play} = $play_in->spawn_floozy($self->{id}, 'width:92%;  background: #005a50; color: #afc; font-weight: bold;');
    $self->{play}->{extra_label} = $self->{cmd};

    $self->{cmd} = shift;
    if ($self->{cmd}) {
        $self->{cmd}  =~ s/<<ID>>/$self->{id}/;

        my $cmd = $self->{cmd};
        $cmd =~ s/\n$//s;
        $cmd = "$$: $cmd\n";

        print "Proc: starting from $cmd";

        write_file("proc/start", {append => 1}, $cmd);
    }
    else {
        say "Proc vacant lot";
    }

    return $self;
}

sub started {
    my $self = shift;
    my $pid = shift;
    $self->{pid} = $pid;

    say "Proc: $self->{id} started ($pid)";

    my $opc = $self->{play}->spawn_floozy("opc");
    my $opc_ch = {
        err => "color: pink; text-shadow: 4px 4px 4px #000;",
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

sub menu {
    my $self = shift;
    return {
        nah => sub {
            $self->nah();
            if ($self->{owner} && $self->{owner}->can('proc_killed')) {
                $self->{owner}->proc_killed($self);
            }
        },
    };
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
