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

sub DESTROY {
    my $self = shift;
    $self->ebug->kill();
}
sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    # TODO viewport objects we can easily interact with without seeing javascript
    $self->code_view($self->hostinfo->provision_view($self, "hodu"));
    $self->exec_view($self->hostinfo->provision_view($self, "view"));

    run("cp -a stylehouse.pl test/");
    run("cp -a lib/*.pm test/lib");

    $self->ebug(Ebuge->new($self, "ebuge.pl", sub {
        $self->drawstuff(shift);
    }));

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
