package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'output';
use Mojo::UserAgent;
use JSON::XS;
use File::Slurp;
use Dumpo;

sub DESTROY {
    my $self = shift;
    $self->killall;
}
sub new {
    my $self = bless {}, shift;
    shift->($self);
    
    $self->{in_things} = $self->hostinfo->set("Codo/in_things", []);
    $self->{dumpo} = Dumpo->new($self->hostinfo->intro, "hodu");

    return $self;
}

sub haveathing {
    my $self = shift;
    
    my $thing = shift;
    push @{ $self->{in_things} }, $thing;
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
