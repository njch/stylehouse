package Proc;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use AnyEvent::Subprocess;
use AnyEvent::Util;
use File::Slurp;
use Time::HiRes 'gettimeofday';

has 'hostinfo';
has 'view';
has 'output';
has 'outhook';
has 'toexec';
has 'pid';
has 'kilt';

# talk to procserv (at the end in ``), setup handlers for its output
sub kill {
    my $self = shift;
    unless ($self->pid) {
        say "! ! killing before Proc got started ! !";
        return;
    }
    kill "INT", $self->pid;
    $self->kilt(1); # tell ebuge somehow (later)
}
sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    $self->toexec(shift);
    my $toexec = $self->toexec;

    $self->outhook(shift);
    $self->output([]);

    my $view = $self->hostinfo->get_view($self, "hodu"); # for printing STDERR, STDOUT: runtime splurge space

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
                $self->gotline($d, $line);
            });
        }
        return 0;
    });
        
    write_file("proc/start", {append => 1}, $self->toexec."\n");
    sleep 1;

    return $self;
}

has 'lastlinepush' => sub { 0 };
has 'queuestarts' => sub { 0 };

sub hitime {
    my $self = shift;
    return join ".", time, (gettimeofday())[1];
}

has 'linepushdelay' => sub { Mojo::IOLoop::Delay->new() };
has 'linepushdelay_on' => sub { 0 };

sub pushlines {
    my $self = shift;

    my @newlines;

    my $last = $self->queuestarts || 0;
    my $first = $last + 1;
    $last = (scalar(@{$self->output})||1)-1;

    push @newlines, @{$self->output}[$first..$last];

    $self->view->{hodu}->text->append(map { join" ",@$_ } @newlines);
    say "Proc: pushed ".scalar(@newlines)." lines outwards";

    $self->queuestarts( $last+1 );
    $self->lastlinepush($self->hitime());
    $self->linepushdelay_on(0);
}

sub gotline {
    my $self = shift;
    my $std = shift;
    my $line = shift;

    say "gotline: $std $line";

    push @{ $self->output }, [ $std, $line ];

    return if $self->linepushdelay_on;

    if ($self->hitime < $self->lastlinepush + 1) {
        
        $self->linepushdelay_on(1);
        $self->linepushdelay->steps(
            sub { Mojo::IOLoop->timer(1 => $self->linepushdelay->begin); say "Pushing lines in 1 second"; },
            sub { $self->pushlines; },
        );
    }
    else {
        $self->pushlines();
    }
}


sub event {
    my $self = shift;
}

1;
