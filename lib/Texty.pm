package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use HTML::Entities;
use Storable 'dclone';
use JSON::XS;
my $json = JSON::XS->new->allow_nonref(1);

has 'hostinfo';
has 'view';
has 'lines';
has 'hooks';

has 'id';
has 'tuxts';
has 'htmls';

has 'empty';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $notakeoveryet = $_[0] && $_[0] eq "..." && shift @_;

    $self->view(shift || die "need owner");
    $self->lines(shift || []);
    $self->hooks(shift || {});

    # make a persistent object for this Texty thing
    # #hodu dump junk will not be saved
    $self->hostinfo->screenthing($self);

    $self->lines_to_tuxts();

    $self->tuxts_to_htmls();
    
    # make leaving here default?
    # the rest could be attracted to View
    # attention shoving should be something that reaches here and figures out whether to...
    return $self if $self->hooks->{notakeover} || $notakeoveryet;

    $self->view->takeover($self->htmls);

    return $self;
}
sub replace {
    my $self = shift;
    my $lines = shift;
    
    $self->lines($lines);
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();
    $self->view->takeover($self->htmls);
}

sub append {
    my $self = shift;
    my @new = @_;
    push @{ $self->lines }, @new;
    $self->lines_to_tuxts();
    $self->tuxts_to_htmls();
    my @newhtml;
    my @allhtml = @{$self->htmls};
    for (1..scalar(@new)) {
        push @newhtml, pop @allhtml;
    }
    if ($self->empty) {
        $self->empty(0);
        $self->view->takeover([@newhtml]);
    }
    else {
        $self->view->takeover([@newhtml], "append");
    }
}

sub lines_to_tuxts {
    my $self = shift;

    if (!@{ $self->lines } && defined($self->empty)) {
        $self->empty(1);
        $self->lines([
            ">nothing<"
        ]);
    }
    else {
        $self->empty(0);
    }

    my $l = 0;
    my @tuxts;
    for my $value (@{ $self->lines }) {
        $value =~ s/\n$//;
        my $tuxt = {
            class => "data",
            id => ($self->view->id.'-'.$self->id.'-'.$l++),
        };

        if (ref $value eq "Texty") {
            $tuxt->{style} .= "border: 1px solid pink;";
            my @inners = @{ $value->tuxt };
            $_->{left} += 20 for @inners;
            push @tuxts, @inners;
        }
        else {
            $value = encode_entities($value)
                unless $value =~ /<span/sgm;
        }

        push @tuxts, {
            class => "data ".$self->view->id,
            id => ($self->id.'-'.$l++),
            value => $value,
        };
    }

    $self->tuxts([@tuxts]);

    $self->spatialise();
}
sub spatialise {
    my $self = shift;
    my $geo = shift || { top => 30, left => 20 };
    for my $s (@{$self->tuxts}) {
        $s->{top} ||= 0;
        $s->{top} = $geo->{top};
        $s->{left} ||= 0;
        $s->{left} += $geo->{left};
        $geo->{top} += 20;
    }
}

sub tuxts_to_htmls {
    my $self = shift;
    if ($self->{hooks}->{tuxts_to_htmls}) {
        $self->{hooks}->{tuxts_to_htmls}->($self);
    }

    my $top_add = 0;
    my @span_htmls;
    for my $s (@{$self->tuxts}) {
        my $mid = { %$s };
        my $value = delete($mid->{value});
        my $p = {};
        if (exists $mid->{inner}) {
            $p->{inner} = delete $mid->{inner};
        }
        my $pm = dclone $mid;
        $p = { %$pm, %$p };

        $p->{style} = join "; ", grep /\S/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;

        my $span_html = "<span $attrstring>$value</span>";
        push @span_htmls, $span_html;
        
    }

    $self->htmls([@span_htmls]);
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;

    $self->owner->event($tx, $event, $self);
}

sub owner {
    my $self = shift;
    my $owner = $self;
    until (ref $owner eq "View") {
        $owner = $owner->view;
    }
    $owner = $owner->owner;
    return $owner;
}


1;
