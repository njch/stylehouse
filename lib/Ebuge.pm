package Ebuge;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';
has 'outhook';

has 'filename';
has 'ready';
has 'hostname';
has 'ua';
has 'proc';

# start a process via Proc (via procserv.pl) and talk web to it
sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    $self->filename(shift);

    $self->outhook(shift);

    $self->ready(0);

    my $port = int(rand(4000)) + 4000;
    $self->hostname("http://127.0.0.1:$port/");

    $self->ua(Mojo::UserAgent->new());

    my $handle_proc_talk = sub {
        my ($d, $line) = @_;
        say "Ebuge $d: $line";
        $self->outhook->(std => [$d, $line]);
        # etc welcome to thursday
    };

    my $perlcall = "perl ".$self->filename." daemon -l ".$self->hostname;

    $self->proc(Proc->new($self, $perlcall, $handle_proc_talk));
    $self->connect();

    return $self;
}

sub kill {
    my $self = shift;
    unless ($self->proc) {
        say "! ! killing before Proc finished starting ! !";
        return;
    }
    $self->proc->kill();
}

sub connect {
    my $self = shift;

    say "Connecting to ebuge...";
    $self->ua->get('http://127.0.0.1:4008/hello' => sub {
        my ($ua, $tx) = @_;
        if (my $error = $tx->res->error) {
            $self->ready(0);
            say "Codo: $error, reconnecting";
            return $self->connect();
        }
        $self->ready(1);
        say "Codo: ebuge responds";
        my $output = decode_json($tx->res->body);
        $self->outhook->($output);
    });
}

has 'next_command';
# save the command if ebug is not ready (we nee
# or run the command
# 
sub trycommand {
    my $self = shift;
    my $command = shift;
    if ($self->r == 0) {
        $self->next_command($command);
        return;

    }
    $command ||= $self->next_command;
    return unless $command;
    say "Going to query ebuge $command";
    $self->ua->get("http://127.0.0.1:4008/exec/$command" => sub {
        my ($ua, $tx) = @_;
        my $output = decode_json($tx->res->body);
        $self->outhook->(exec => $output);
        say anydump($output);
    });
    say "starting loop...";
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
    say "wandering off...";
}

1;
