package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;

has 'hostinfo';
has 'output';
has 'outhook';
has 'command';
has 'pid';

# talk to procserv (at the end in ``), setup handlers for its output
sub kill {
    my $self = shift;
    unless ($self->pid) {
        say "! ! killing before Proc got started ! !";
        return;
    }
    $self->run->kill(2); # SIGINT
}
sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    my $command = $self->command(shift);

    $self->outhook(shift);
    $self->output([]);

    say "Proc: starting ".$self->command;

    $self->hostinfo->stream_file("proc/list", sub {
        my $line = shift;
        chomp $line;
        my ($pid, $command_echo) = $line =~ /^(\d+): (.+)$/;
        say "Proc: started $pid for $command_echo";
        die "weird: $command_echo $command" unless $command_echo eq $command;

        $self->pid($pid);
        
        for my $d ("err", "out") {
            $self->hostinfo->stream_file("proc/$pid.$d", sub {
                my $line = shift;
                push @{ $self->output }, [ $d, $line ];
                $self->outhook->($d, $line);
            });
        }
    });
        
    `echo $command >> proc/start`;

    return $self;
}

1;
