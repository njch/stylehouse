package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;

has 'owner';
has 'lines';
has 'spans';
has 'jquery';
has 'view'; # Set this up
has 'hooks';
has 'id';

sub new {
    my $self = bless {}, shift;
    $self->owner(shift);
    $self->lines(shift);
    $self->view(shift || "view");
    $self->hooks(shift);
    if ($self->view eq "hodu") {
        # hide from screen cares
    }
    else {
        # ugly swooping
        my $hostinfo = $self->owner->app->hostinfo;
        # make a persistent object for this Texty thing
        $hostinfo->screenthing($self);
    }
    $self->lines_to_spans();
    $self->spans_to_jquery();
    $self->owner->app->send($self->jquery);
}

sub lines_to_spans {
    my $self = shift;
    my $es = $self->lines;
    my $id = $self->id;
    my $top = 20;
    my $left = 20;
    my @spans;
    my $l = 0;
    for my $e (@$es) {
        push @spans, {
            class => "data", id => ($id.'-'.$l++),
            top => ($top += 20), left => $left,
            value => $e,
        };
    }
    $self->spans([@spans]);
}

sub spans_to_jquery {
    my $self = shift;
    if ($self->{hooks}->{span2jquery}) {
        $self->{hooks}->{span2jquery}->($self);
    }
    my $spans = $self->spans;
    my $viewid = $self->view;
    my @jquery;
    for my $s (@$spans) {
        my $p = { %$s };
        my $value = delete($p->{value});
        $p->{style} = join "; ",
            ($p->{top} ? "top: ".delete($p->{top})."px" : ''),
            ($p->{left} ? "left: ".delete($p->{left})."px" : ''),
            ($p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } keys %$p;
        my $spanstring = "<span $attrstring>$value</span>";
        push @jquery, "  \$('#$viewid').append('$spanstring');";
    }
    push @jquery, "  \$('#$viewid').on('click', clickyhand);";
    $self->jquery(join"\n", @jquery);
}

sub set {
    my ($self, $i, $d) = @_;
}

sub event {
    my $self = shift;
    my $event = shift;

    $self->owner->app->send("\$('#$event->{id}').css('color', 'red');");
}

1;
