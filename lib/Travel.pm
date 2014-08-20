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
    $self->{name} = Ghost::gname($O);
    say "+T $self->{name}";
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
    $self->{G}->ob(@_);
}
sub T {
    my $T = shift;
    my $t = shift;
    my $G = shift || $T->G; # A...
    my $i = shift;
    my $depth = shift || 0;
    
    $G->Flab("T", $t, $t, $G, $i, $depth);
    
    my ($L, $o) = $G->haunt($T, $depth, $t, $i);

    my @r = $T->W;
    for my $c (@$o) {
        if (exists $c->{travel_this}) {
            $T->T($c->{travel_this}, $G, $c, $depth+1);
        }
        elsif (exists $c->{arr_returns}) {
            @r = @{$c->{arr_returns}};
        }
        elsif (exists $c->{B}->{s}) {
            # sweet
        }
        else {
            $H->error("what kind of way out is",Ghost::ki($c))
        }
    }
    $G->w("T_end", {L=>$L, r=>\@r});

    return wantarray ? @r : shift @r;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

