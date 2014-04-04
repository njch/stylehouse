package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'view' => sub { {} };
has 'ebug';
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub DESTROY {
    my $self = shift;
    $self->ebug->kill() if $self->ebug;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, "hodu")->text([], { skip_hostinfo => 1 });
    $self->hostinfo->get_view($self, "view")->text([], { skip_hostinfo => 1 });
    $self->hostinfo->get_view($self, "hodi")->text([], { skip_hostinfo => 1 });

    run("cp -a stylehouse.pl test/");
    run("cp -a lib/*.pm test/lib");

    $self->ebug(Ebuge->new($self->hostinfo->intro, "ebuge.pl"));

    return $self;
}



sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
