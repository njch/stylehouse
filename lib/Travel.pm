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

    my $O = $self->{O} = shift || die "no O";
    $self->{from} = [$O, @_];
    $self->{name} = ref $O && ($self->{O}->{name} || $self->{O}->{id}) || "$O";

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
    return unless $self->{TT};
    
    my $ob = $H->enlogform(@_); # describes stack, etc
    push $ob, [@Ghost::F], pop $ob;
# we want to catch runaway recursion from here
    $self->{TT}->T($ob);
}

# the wormhole for self
# so G can make higher frequency W inside a singular T
# self awareness
sub T {
    my $T = shift;
    my $t = shift;
    my $G = shift || $T->G; # A...
    my $i = shift;
    my $depth = shift || 0;
    my $last_line = shift;
    
    $T->ob("Travel", $depth, $t);
    (my $td = $t||"~") =~ s/\n/\\n/g;
    say("$T->{id} ".$G->idname."            $depth to $td    ".($i?($i->{K}||$i->{name}):"?")) unless $G->{name} =~ /Lyrico\/ob/;
    
    my ($line, $o) = $G->haunt($T, $depth, $t, $i, $last_line);

    my @r = $T->W;
    for my $c (@$o) {
        if (exists $c->{travel_this}) {
            $T->T($c->{travel_this}, $G, $c, $depth+1, $line);
        }
        elsif (exists $c->{arr_returns}) {
            @r = @{$c->{arr_returns}};
        }
        else {
            die "what kind of way out is ".ddump($c);
        }
    }

    return @r;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

