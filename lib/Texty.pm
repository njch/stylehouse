package Texty;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use HTML::Entities;
use Storable 'dclone';
use JSON::XS;
my $json = JSON::XS->new->allow_nonref(1);

has 'owner';
has 'hostinfo';
has 'lines';
has 'spans';
has 'jquery';
has 'view'; # Set this up
has 'hooks';
has 'id';

sub new {
    my $self = bless {}, shift;
    $self->owner(shift);
    $self->hostinfo($self->owner->hostinfo);
    $self->lines(shift);
    ref $self->lines eq "ARRAY" || die "need arrayref";
    $self->hooks(shift || {});
    $self->view($self->hooks->{view} || "hodu");
    # ugly swooping
    my $hostinfo = $self->owner->hostinfo;
    # make a persistent object for this Texty thing
    # #hodu dump junk will not be saved
    $hostinfo->screenthing($self);
    $self->lines_to_spans();
    $self->spans_to_jquery();
    $hostinfo->send($self->jquery."\n") unless $self->hooks->{notx};
    return $self;
}

sub lines_to_spans {
    my $self = shift;
    my $es = $self->lines;
    my $id = $self->id;
    my $top = 20;
    my $spacer = sub { top => ($top += 20) };
    my @spans;
    my $l = 0;
    for my $e (@$es) {
        push @spans, {
            class => "data", id => ($id.'-'.$l++),
            $spacer->(),
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
    my @span_htmls;
    for my $s (@$spans) {
        my $p = dclone $s;
        my $value = delete($p->{value});
        $p->{style} = join "; ", grep /\S/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;


        if ($value =~ /<span/) {
            # something's taking care of it
        }
        else {
            $value = encode_entities($value);
        }
        my $span_html = "<span $attrstring>$value</span>";
        push @span_htmls, $span_html;
        
    }
    if ($self->{hooks}->{catch_span_htmls}) {
        $self->{hooks}->{catch_span_htmls}->($self, @span_htmls);
    }
    my @jquery;
    push @jquery, "  \$('#$viewid').append(".$json->encode(join('', @span_htmls)).");";
    $self->jquery(join"\n", @jquery);
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;

    $tx->send("\$('#$event->{id}').css('color', 'red');");
    $self->owner->event($tx, $event, $self);
}

1;
