package Dumpo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';
has 'view';

sub new {
    my $self = bless {}, shift;
    $self->hostinfo(shift->hostinfo);
    my $object = shift;

    $self->view("hodu");

    $self->hostinfo->set('Dumpo', $self);
    $self->updump($object, "init");

    return $self;
}

sub menu {
    my $self = shift;
    return {
        updump => sub {
            $self->updump;
            my $event = shift;
            $self->hostinfo->send(
                "\$('#$event->{id}').delay(100).fadeOut().fadeIn('slow')");
        },
    };
}

sub updump {
    my $self = shift;
    my $object = shift;
    my $init = shift;
    if (0 && !$init) {
        $self->hostinfo->send("\$('#".$self->view." span').remove();");
    }
        
    my $dump = $object ? anydump($object) : $self->hostinfo->dump("dontsay");
    use File::Slurp;
    write_file('public/dump', $dump);
    #my $text = new Texty($self, [grep { !/^       / } split("\n", $dump)],
    #    { view => $self->view,
    #    skip_hostinfo => 1 }
    #);
}

1;
