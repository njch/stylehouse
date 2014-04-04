package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;
use File::Slurp;

has 'hostinfo';
has 'view';
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

    my $view = $self->hostinfo->get_view($self, "hodi"); # for printing STDERR, STDOUT
    $view->text([],
        { tuxts_to_htmls => sub {
            my $texty = shift;
            return if $texty->empty;
            for my $t (@{ $texty->tuxts }) {
                next unless $t->{value} =~ s/(err|std) //;
                $t->{style} .= "font-color: ".($1 eq "err" ? "#95e" : $1 eq "std" ? "#022" : die("no prefix? $t->{value}")).";";

            }
        }},
    );

    say "Proc: starting ".$self->toexec;

    # watch the list of started files and their pids

    $self->hostinfo->stream_file("proc/list", sub {
        my $line = shift;
        chomp $line;
        unless ($line =~ /\S+/) {
            return 0;
        }
        sleep 1;

        my ($pid, $toexec_echo) = $line =~ /^(\d+): (.+)$/;
        say "Proc: started $pid for $toexec_echo";
        say "ww  ww  ww eird: $toexec_echo $toexec" unless $toexec_echo eq $toexec;

        $self->pid($pid);
        
        # PRINT CODSOLE
        for my $d ("err", "out") {
            $self->hostinfo->stream_file("proc/$pid.$d", sub {
                my $line = shift;
                push @{ $self->output }, [ $d, $line ];

                $self->view->{hodi}->text->append("$d $line");
            });
        }
        return 0;
    });
        
    write_file("proc/start", {append => 1}, $self->toexec."\n");
    sleep 1;

    return $self;
}

1;
