package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Ghost;
sub ddump { Hostinfo::ddump(@_) }
has 'cd';
our $H;
sub new {
    my $self = bless {}, shift;
    shift->($self);
    delete $self->{hostinfo};

    $self->{O} = shift || die "no O";
    $self->{from} = [$self->{O}, @_];
    $self->{name} = $self->{O}->{name} || $self->{O}->{id};

    return $self;
}
sub G {
    my $self = shift;
    $self->{G} ||= new Ghost($H->intro, $self, @_);
}
sub W {
    shift->G->W
}
sub ob {
    my $self = shift;
    return;# unless $self->{TT};
    
    my $ob = $H->enlogform(@_); # describes stack, etc
# we want to catch runaway recursion from here
    $self->{TT}->T($ob);
}

# the wormhole for self
# so G can make higher frequency W inside a singular T
# self awareness
sub travel {
    my $self = shift;
    my $t = shift;
    my $G = shift || $self->G;
    my $i = shift;
    my $depth = shift || 0;
    my $last_line = shift;
    
    $self->ob("Travel", $depth, $t);
    (my $td = $t||"~") =~ s/\n/\\n/g;
    say("Travel $G->{name}            $depth to $td    ".($i?($i->{K}||$i->{name}):"?"));
    
    my ($line, $o) = $G->haunt($depth, $t, $i, $last_line);

    my @r;
    for my $c (@$o) {
        if (exists $c->{travel_this}) {
            $self->travel($c->{travel_this}, $G, $c, $depth+1, $line);
        }
        elsif (exists $c->{travel_returns}) {
            push @r, @{$c->{travel_returns}};
        }
        else {
            die "what kind of way out is ".ddump($c);
        }
    }
    push @r, $self->W unless @r;

    return @r;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

