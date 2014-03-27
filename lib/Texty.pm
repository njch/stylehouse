package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use HTML::Entities;

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
    # ugly swooping
    my $hostinfo = $self->owner->app->hostinfo;
    # make a persistent object for this Texty thing
    # #hodu dump junk will not be saved
    $hostinfo->screenthing($self);
    $self->lines_to_spans();
    $self->spans_to_jquery();
    $self->owner->app->send($self->jquery);
}

sub lines_to_spans {
    my $self = shift;
    my $es = $self->lines;
    my $id = $self->id;
    my $top = 20;
    my @spans;
    my $l = 0;
    for my $e (@$es) {
        push @spans, {
            class => "data", id => ($id.'-'.$l++),
            top => ($top += 20),
            value => $e,
        };
    }
    $self->spans([@spans]);
}

sub spans_to_jquery {
    my $self = shift;
    if ($self->{hooks}->{spans_to_jquery}) {
        $self->{hooks}->{spans_to_jquery}->($self);
    }
    my $spans = $self->spans;
    my $viewid = $self->view;
    my @jquery;
    for my $s (@$spans) {
        my $p = { %$s };
        my $value = delete($p->{value});
        $p->{style} = join "; ", grep /\S/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        say anydump($p);
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;
        my $spanstring = "<span $attrstring>".encode_entities($value)."</span>";
        push @jquery, "  \$('#$viewid').append('".$spanstring."');";
    }
    push @jquery, "  \$('#$viewid span.data').on('click', clickyhand);";
    $self->jquery(join"\n", @jquery);
}

sub set {
    my ($self, $i, $d) = @_;
}

sub event {
    my $self = shift;
    my $event = shift;

    $self->owner->app->send("\$('#$event->{id}').css('color', 'red');");
    $self->owner->event($event, $self);
}

1;
