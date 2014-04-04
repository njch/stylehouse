package Ebuge;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use File::Slurp;
use JSON::XS;

has 'cd';
has 'hostinfo';
has 'view';
has 'outhook';

has 'filename';
has 'ready';
has 'hostname';
has 'ua';
has 'proc';

# start a process via Proc (via procserv.pl) and talk web to it
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, "hodi");

    $self->filename(shift);

    $self->ready(0);

    my $port = int(rand(4000)) + 4000;
    $self->hostname("http://127.0.0.1:$port/");

    $self->ua(Mojo::UserAgent->new());

    my $handle_proc_talk = sub {
        my ($d, $line) = @_;
        # say "Ebuge $d: $line";
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

my $first = 1;
sub connect {
    my $self = shift;

    say "Ebuge: Connecting to ebuge..." if $first;
    $self->ua->get($self->hostname.'/hello' => sub {
        my ($ua, $tx) = @_;
        if (my $error = $tx->res->error) {
            $self->ready(0);
            say "Ebuge: $error, reconnecting..." if $first;
            $first = 0;
            my $delay = Mojo::IOLoop::Delay->new();
            $delay->steps(
                sub { Mojo::IOLoop->timer(2 => $delay->begin); },
                sub { $self->connect },
            );
        }
        $self->ready(1);
        say "Ebuge: ebuge responds";
        my $output = $tx->res->body;
        if ($output =~ /<!DOCTYPE html>/) {
            write_file('public/ebugewebpage', $output);
            $output = "Wrote ebugwebpage";
        }
        else {
            $output = decode_json($output) if $output;
        }
        $self->drawstuff($output);
    });
}

sub menu {
    my $self = shift;
    my $menu = {};
    for my $i (qw{next step run undo stack_trace pad}) {
        $menu->{$i} = sub { $self->trycommand($i) };
    }
    $menu->{"load"} = sub {
        # restart the process?
        say "code load!";
    };
    return $menu;
}


sub drawstuff {
    my $self = shift;
    my $output = shift;

    if ($output eq "Wrote ebugwebpage") {
        $output = 'Wrote <a ref="/ebugwebpage" style="font-size: 30">ebugwebpage</a>';
        $self->view->{hodi}->text->append($output);
        return;
    }
    if ($output eq "") {
        $output = 'Got a blank response';
        $self->view->{hodi}->text->append($output);
        return;
    }

    # CODE
    my @lines = lines_for_file($output->{filename});
    my $current = $output->{line};

    if ($current) {
        my $from = $current - 10;
        $from = 0 if $from < 0;
        @lines = splice @lines, $from, 20;
        $current = 10;
    }

    
    $self->hostinfo->send("\$('#".$self->code_view->{id}." span').fadeOut(500);");

    $self->view->{hodi}->text->replace([]);
    my $text = new Texty($self, [@lines],
        { view => $self->code_view->{id} }
    );

    my $spanid = $text->tuxts->[$current-1]->{id};
    $self->hostinfo->send("\$('#$spanid').addClass('on');");

    # EXEC
    my @exec;

    if ($output->{finished}) {
        push @exec, "Finished!";
    }
    else {
        push @exec, 
            "In subroutine: " . $output->{package}.'::'.$output->{subroutine},
            "Line ". $output->{line} ." in ". $output->{filename},
            "Code: "          . $output->{codeline},
    };
    if ($output->{command} && $output->{command} eq "pad") {
        push @exec, split "\n", anydump(delete $output->{return}); # the ocean lies this way
    }
    push @exec,
            "OUTPUT: <span class=\"on\"> $output->{stdout} $output->{stderr} </span>";

    $self->hostinfo->send("\$('#".$self->exec_view->{id}." span').fadeOut(500);");

    $self->view->{hodi}->text->replace([@exec]);
}

sub lines_for_file {
    my $filename = shift;
    return split "\n", read_file($filename);
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
    $self->ua->get($self->hostname."/exec/$command" => sub {
        my ($ua, $tx) = @_;
        my $output = decode_json($tx->res->body);
        $self->outhook->($output);
        say "! !!! @$output";
        say anydump($output);
    });
    say "starting loop...";
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
    say "wandering off...";
}

1;
