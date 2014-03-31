package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use Devel::ebug;

has 'hostinfo';
has 'code_view';
has 'exec_view';
has 'ebug';
has 'codelines';

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    my $ebug = Devel::ebug->new;
    $self->ebug($ebug);
    $ebug->program('ordilly.pl');
    $ebug->load;

    # TODO viewport objects we can easily interact with without seeing javascript
    $self->code_view($self->hostinfo->provision_view($self, "hodu"));
    $self->exec_view($self->hostinfo->provision_view($self, "view"));

    $self->source();
    $self->ebug_exec();


    return $self;
}

sub menu {
    my $self = shift;
    my $menu = {};
    for my $i (qw{next step run}) {
        $menu->{$i} = sub { $self->ebug->$i(); $self->ebug_exec(); };
    }
    for my $i (qw{stack_trace}) {
        $menu->{$i} = sub { $self->ebug_exec($self->ebug->$i(), shift); };
    }
    return $menu;
}

sub source {
    my $self = shift;
    my @lines = $self->ebug->codelines;
    
    my $text = new Texty($self, [@lines],
        { view => $self->code_view->{id} }
    );
    $self->codelines($text);
}

sub ebug_exec {
    my $self = shift;
    my $ebug = $self->ebug;
    my $output = shift;
    my $event = shift;

    if ($output) {
        new Texty($self, [ split "\n", $output ],
            { view => $self->exec_view->{id},
            skip_hostinfo => 1 }
        );
    }

    
    $self->hostinfo->send("\$('#".$self->exec_view->{id}." span').fadeOut(500);");
    my ($stdout, $stderr) = $ebug->output;
        
    my @lines;
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
    push @lines,
            "OUTPUT: <span class=\"on\"> $stdout $stderr </span>";

    $self->hostinfo->send("\$('#".$self->codelines->view." span').removeClass('on');");
    my $span = $self->codelines->spans->[$ebug->line-1]->{id};
    $self->hostinfo->send("\$('#$span').addClass('on');");

    my $text = new Texty($self, [@lines],
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
