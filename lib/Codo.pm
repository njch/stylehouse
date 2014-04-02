package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'code_view';
has 'exec_view';
has 'ebug';
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    # TODO viewport objects we can easily interact with without seeing javascript
    $self->code_view($self->hostinfo->provision_view($self, "hodu"));
    $self->exec_view($self->hostinfo->provision_view($self, "view"));

    run("cp -a stylehouse.pl test/");
    run("cp -a lib/*.pm test/lib");
    

#    system("perl ebuge.pl &");

    $self->connect();

    return $self;
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


sub connect {
    my $self = shift;
    unless ($self->ebug) {
        my $ua = Mojo::UserAgent->new();
        my $uar = {
            ua => $ua,
            r => 0,
        };
        $self->ebug($uar);
    }

    say "Connecting to ebuge...";
    say " is running: ". Mojo::IOLoop->is_running;
    $self->ebug->{ua}->get('http://127.0.0.1:4008/hello' => sub {
        my ($ua, $tx) = @_;
        if ($tx->res->error) {
            say "Ebuge fucked up: ".$tx->res->error;
            return;
        }
        $self->ebug->{r} = 1;
        say "EBUGE SAY HELLO TO US!";
        my $output = decode_json($tx->res->body);
        $self->drawstuff($output);
        say anydump($output);
        $self->trycommand(); # send pending commands
        say "...";
    });
    say " is running: ". Mojo::IOLoop->is_running;
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
    say "Here!";
}

has 'next_command';
# save the command if ebug is not ready (we nee
# or run the command
# 
sub trycommand {
    my $self = shift;
    my $command = shift;
    if ($self->ebug->{r} == 0) {
        $self->next_command($command);
        return;

    }
    $command ||= $self->next_command;
    return unless $command;
    say "Going to query ebuge $command";
    $self->ebug->{ua}->get("http://127.0.0.1:4008/exec/$command" => sub {
        my ($ua, $tx) = @_;
        my $output = decode_json($tx->res->body);
        $self->drawstuff($output);
        say anydump($output);
    });
}

sub drawstuff {
    my $self = shift;
    my $output = shift;
    say "HEEEEEER";

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
    my $text = new Texty($self, [@lines],
        { view => $self->code_view->{id} }
    );

    my $span = $text->spans->[$current-1]->{id};
    $self->hostinfo->send("\$('#$span').addClass('on');");

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
    $text = new Texty($self, [@exec],
        { view => $self->exec_view->{id},
        skip_hostinfo => 1 }
    );
}

sub lines_for_file {
    my $filename = shift;
    return split "\n", read_file($filename);
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
