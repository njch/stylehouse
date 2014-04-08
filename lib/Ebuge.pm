package Ebuge;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use File::Slurp;
use JSON::XS;

has 'cd';
has 'hostinfo';
has 'ports';
has 'outhook';

has 'filename';
has 'ready';
has 'hostname';
has 'ua';
has 'proc';

our $ebuges = [];
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

    push @$ebuges, $self;
    say "Making another ebuge: ".$self->hostname if @$ebuges > 1;

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
    # TODO delete views
}

sub connect {
    my $self = shift;

    say "Ebuge: Connecting to ebuge...";
    $self->ua->get($self->hostname.'/hello' => sub {
        my ($ua, $tx) = @_;

        my $new;
        my $output = $tx->res->body;
        my $error = $tx->res->error;

        if ($error) {
            $self->ready(0);
            say "Ebuge: $error";
            my $e = {};
            $e->{error} = $error;

            if ($output =~ /<!DOCTYPE html>/) {
                $e->{pagetitle} = $1 if $output =~ /<title>(.*)<\/title>/;

                # great value conjuring syntax: .+?
                $e->{request} = "request for $1 '$2'" if $output =~ /<code>(.+?)<\/code> request for \s+ <code>(.+?)<\/code>/;

                $e->{hasroutes} = 1 if $output =~ /<pre>\/hello<\/pre>.+<pre>\/exec\/:command<\/pre>/s;
            }

            write_file("public/ebuge_reply_page", $output);
            $e->{body} = 'See /ebuge_reply_page Page From ebuge.pl';

            $e = [ "Ebug has fucked up: ", split "\n", anydump($e) ];
            $new = { error => $e };
        }
        else {
            $@ = "";
            eval {
                $new = decode_json($output) if $output;
            };
            if ($@) {
                $new = [ "Error decoding output: ", split "\n", anydump($output) ];
                $new = { error => $new }; 
            }
        }

        $self->drawstuff($new);
    });
}

sub menu {
    my $self = shift;
    my $menu = {};
    for my $i (qw{next step run undo stack_trace pad}) {
        $menu->{$i} = sub { $self->trycommand($i) };
    }
    $menu->{"reload"} = sub {
        # restart the process?
        $self->kill;
    };
    return $menu;
}


sub drawstuff {
    my $self = shift;
    my $output = shift;

    if ($output->{error}) {
        $self->view->{hodi}->text->replace($output->{error});
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

sub event {
    my $self = shift;
    my $event = shift;
}

1;
