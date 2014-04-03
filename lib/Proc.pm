package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;
use File::Slurp;

has 'hostinfo';
has 'output';
has 'outhook';
has 'toexec';
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

    $self->toexec(shift);
    my $toexec = $self->toexec;

    $self->outhook(shift);
    $self->output([]);

    say "Proc: starting ".$self->toexec;

    $self->hostinfo->stream_file("proc/list", sub {
        my $line = shift;
        chomp $line;
        unless ($line =~ /\S+/) {
            return 0;
        }
        sleep 1;

        my ($pid, $toexec_echo) = $line =~ /^(\d+): (.+)$/;
        say "Proc: started $pid for $toexec_echo";
        die "weird: $toexec_echo $toexec" unless $toexec_echo eq $toexec;

        $self->pid($pid);
        
        for my $d ("err", "out") {
            $self->hostinfo->stream_file("proc/$pid.$d", sub {
                my $line = shift;
                push @{ $self->output }, [ $d, $line ];
                $self->outhook->($d, $line);
            });
        }
        return 0;
    });
        
    write_file("proc/start", {append => 1}, $self->toexec."\n");
    sleep 1;

    return $self;
}

1;
