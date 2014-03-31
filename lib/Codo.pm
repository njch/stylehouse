package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

use Devel::ebug;

has 'hostinfo';
has 'code_view';
has 'exec_view';
has 'ebug';

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    $self->hostinfo->intro($self);

    my $ebug = Devel::ebug->new;
    $self->ebug($ebug);
    $ebug->program('ordilly.pl');
    $ebug->load;

    # TODO viewport objects we can easily interact with without seeing javascript
    $self->code_view($self->hostinfo->provision_view($self, "view"));
    $self->exec_view($self->hostinfo->provision_view($self, "hodu"));

    $self->ebug_view();

    return $self;
}

sub menu {
    my $self = shift;
    return {
        next => sub {
            $self->ebug->step();
            $self->ebug_view();
            my $event = shift;
            $self->hostinfo->send(
                "\$('#$event->{id}').delay(100).fadeOut().fadeIn('slow')",
            );
        },
    };
}

sub ebug_view {
    my $self = shift;
    my $ebug = $self->ebug;
    
    $self->hostinfo->send("\$('#".$self->exec_view->{id}." span').fadeOut(500);");
        
    my @lines = (
        "At line: "       . $ebug->line       . "\n",
        "In subroutine: " . $ebug->subroutine . "\n",
        "In package: "    . $ebug->package    . "\n",
        "In filename: "   . $ebug->filename   . "\n",
        "Code: "          . $ebug->codeline   . "\n",
    );

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
