package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use Devel::ebug;

has 'hostinfo';
has 'code_view';
has 'exec_view';
has 'ebug';
has 'output';

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    # TODO viewport objects we can easily interact with without seeing javascript
    $self->code_view($self->hostinfo->provision_view($self, "hodu"));
    $self->exec_view($self->hostinfo->provision_view($self, "view"));

    $self->load();
    $self->ebug_exec();


    return $self;
}

sub load {
    my $self = shift;

    run("cp -a stylehouse.pl test/");
    run("cp -a lib/*.pm test/lib");

    $self->output([]);

    my $ebug = Devel::ebug->new;
    $self->ebug($ebug);
    $ebug->program('test/stylehouse.pl');
    $ebug->load;

    # litter it with places to wait
# might even need a middleware so we can consider the jam instead of just jamming
    my @filenames    = $ebug->filenames();
    @filenames = grep { /^lib|stylehouse\.pl$/ } @filenames;
    for my $filename (@filenames) {
        my $code = capture("cat $filename");
        my @codelines = split "\n", $code;
        my $line = 0;
        for my $codeline (@codelines) {
            if ($codeline =~ /my \$self = shift;/) {
                $self->ebug->break_point($filename, $line);
            }
            $line++;
        }
    }
}

sub menu {
    my $self = shift;
    my $menu = {};
    for my $i (qw{next step run undo}) {
        $menu->{$i} = sub { $self->ebug->$i(); $self->ebug_exec(); };
    }
    $menu->{undo} = sub {
        my $response = $self->ebug->talk({ command => "commands" });
        if (!$response) {
            say "It's only just begun!";
            return;
        }
        $self->ebug->undo();
        $self->ebug_exec();
    };
    for my $i (qw{stack_trace pad}) {
        $menu->{$i} = sub { $self->ebug_exec([$self->ebug->$i()], shift, $i); };
    }
    $menu->{"load"} = sub {
        $self->load;
        $self->ebug_exec();
    };
    return $menu;
}

sub ebug_exec {
    my $self = shift;
    my $ebug = $self->ebug;
    my $output = shift;
    my $event = shift;
    my $command = shift;

    # CODE
    my @lines = $self->ebug->codelines;
    my $current = $self->ebug->line;

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
    if ($output) {
        if ($command eq "pad") {
            $output = [ split "\n", anydump($output) ]; # the ocean lies this way
        }
        unshift @$output, "Output from $command:";
    }

    
    my ($stdout, $stderr) = $ebug->output;
        
    @lines = ();
    if ($ebug->finished) {
        @lines = "Finished!";
    }
    else {
        @lines = (       
            "In subroutine: " . $ebug->package.'::'.$ebug->subroutine,
            "Line ". $ebug->line ." in ". $ebug->filename   . "\n",
            "Code: "          . $ebug->codeline   . "\n",
        );
    };
    push @lines, @$output if $output;
    push @lines,
            "OUTPUT: <span class=\"on\"> $stdout $stderr </span>";

    $self->hostinfo->send("\$('#".$self->exec_view->{id}." span').fadeOut(500);");
    $text = new Texty($self, [@lines],
        { view => $self->exec_view->{id},
        skip_hostinfo => 1 }
    );
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
