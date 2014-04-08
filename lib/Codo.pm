package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'view' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;

sub DESTROY {
    my $self = shift;
    $self->killall;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->hostinfo->get_view($self, "hodu")->text([], { skip_hostinfo => 1 });
    $self->hostinfo->get_view($self, "view")->text([], { skip_hostinfo => 1 });
    $self->hostinfo->get_view($self, "hodi")->text([], { skip_hostinfo => 1 });

    run("cp -a stylehouse.pl test/");
    run("cp -a lib/*.pm test/lib");

    $self->new_ebuge();

    return $self;
}

sub killall {
    my $self = shift;
    for my $ebuge (@{ $self->ebuge }) {
        unless ($ebuge) {
            say "weird, no ebuge...";
            next;
        }
        $ebuge->kill;
    }
    $self->ebuge([]);
}

sub new_ebuge {
    my $self = shift;
    my $ebuge = Ebuge->new($self->hostinfo->intro, "ebuge.pl");
    push @{ $self->ebuge }, $ebuge;
    return $ebuge;
}

sub menu {
    my $self = shift;
    my $menu = {};
    $menu->{"killall"} = sub { $self->killall };
    $menu->{"new"} = sub { $self->new_ebuge() };

    return $menu;
}



sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
