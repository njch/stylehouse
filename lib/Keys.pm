package Keys;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'view' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
has 'ports';
has 'started';

use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;
sub new {
    my $self = bless {}, shift;
    shift->($self);

    return if $self->hostinfo->get("Keys");

    $self->hostinfo->send(
        '$( "#whichkey" ).on( "keydown", function( event ) {  ws.reply({Keys: event});  $( "#log" ).html( event.type + ": " +  event.which );'
    );

    
    say "Made keys";
    return $self;
}
sub start {
    my $self = shift;
    
    $self->started(1);
    $self->ports->{gear}->text(
    );
}
sub stop {
    my $self = shift;
    
    $self->started(1);
    $self->gear->nah;
    $self->gr;
}

# garbage robot
sub gr {
    my $self = shift;
}
sub menu {
    my $self = shift;
    my $menu = {
        '.' => sub {
            if ($self->started) {
                $self->stop;
            }
            else {
                $self->start;
            }
        },
    };

    return $menu;
}

# where they come in, like event but lingo for sleek
sub key {
    my $self = shift;
    my $key = shift;
    #blah
    # chunk away the input
    # always able to hit space
    # tap out a vibe id :O
}
sub event {
    my $self = shift;
    my $event = shift;
}

1;

