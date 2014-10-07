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
    $self->{G} ||= do {
        my $GG = new Ghost($H->intro, $self, @_);
        push @{$H->{G}->{GG}}, $GG;
        $GG
    }
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

    my $flab = $G->Flab("T", $T, $t, $G, $i, $depth);
    if (!$i) {
        $i = $G->w("T_default_wayin");
        $i ||= $G->nw()->from({K=>'T?',flab=>$flab});
    }
    
    my @r = $G->haunt($T, $depth, $t, $i);

    return wantarray ? @r : shift @r;
}
sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;

