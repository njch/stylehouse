package Codo;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;


has 'hostinfo';
has 'ports' => sub { {} };
has 'ebuge' => sub { [] };
has 'codeview';
has 'runview';
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
    
    $self->codeview($self->hostinfo->get_view($self, "hodu"));
    $self->runview($self->hostinfo->get_view($self, "hodi"));

    $self->{pics} = $self->hostinfo->set("Codo/pics", {});
    $self->{code_breaks} = $self->hostinfo->set("Codo/code_breaks", []);

    return $self;
}

sub thedump {
    my $self = shift;
    my $dumpo = $self->hostinfo->get("Dumpo") || die;
    $dumpo->thedump(@_);
}

# break happening
sub take_picture {
    my $self = shift;
    my $picid = shift;
    my @seen = @_;

    my $stack = [ map { [ caller($_) ] } 0..10 ];

    my $pic;
    unless ($pic = $self->{pics}->{$picid}) {
        say "Codo: no such $picid, adding";
        my $f = $stack->[0];
        $f = "$f->[0] $f->[3] ($f->[1] $f->[2])";
        $pic = $self->{pics}->{$picid} = {
            picid => $picid,
            name => "Rogue from $f",
            pics => [],
        };
    }

    my $picturehooks = $pic->{hooks};

    my $picture = [$self->thedump(\@seen, $picturehooks)];
    push @{$pic->{pics}}, {
        stack => $stack,
        picture => $picture,
    };
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
