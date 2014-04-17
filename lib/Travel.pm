package Travel;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'cd';
has 'hostinfo';

sub new {
    my $self = bless {}, shift;
    shift->($self);
    my $self->{hooks} = shift;

    return $self;
}


sub flood {
    my $self = shift;
    my $object = shift;
    my $init = shift;
    if (!$init) {
        $self->hostinfo->send("\$('#".$self->ports->{hodi}->id." span').fadeOut(500);");
    }
   
    $object ||= $self->hostinfo->data;

    $self->ports->{hodi}->text->replace([$self->travel($object)]);
}

# stack of ghosts...
sub travel {
    my $self = shift;
    my $thing = shift;
    my $ghost = shift;


    if (!$ghost) {
        $ghost = new Ghost($self->hostinfo->intro, $


    push @$ghost, {
        ref => "HASH",
        for => sub { sort keys %{$_[0]} },
        travel => sub { $_[0]->{$_[1]} },
    }, {
        ref => "Texty",
        note => sub { owner => $_->view->owner },
    }
    ;

    my @dump = border($thing, $ghost);
    return @dump;
}
sub border {
    my $thing = shift;
    my $ghosties = shift;
    my $depth = shift;
    $depth = 1;
    my @lines;
    my $ignore;

    my $dohook = sub {
        my $h = shift;
        my $d;
        if ($h->{getlines}) {
            push @lines, $h->{getlines}->($thing, $hooks, $depth);
        }
        else {
            say "                   NO SOLUTION?";
        }
    };
    my $scanhooks = sub {
        for my $h (@$hooks) {
            if ($h->{ref}) {
                if (ref $thing eq $h->{ref}) {
                    $dohook->($h) && return 1;
                    last;
                }
            }
        }
    };
    unless ($scanhooks->()) {
        push @lines, "? $thing";
    }
    ref $_ || s/^/('  ')x$depth/e for @lines;
    return @lines;
}

sub event {
    my $self = shift;
    my $event = shift;
    #blah
}

1;
