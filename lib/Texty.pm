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
    $self->hostinfo->intro($self);

    $self->lines(shift);

    ref $self->lines eq "ARRAY" || die "need arrayref";

    $self->hooks(shift || {});
    $self->view($self->hooks->{view} || "hodu");

    # make a persistent object for this Texty thing
    # #hodu dump junk will not be saved
    $self->hostinfo->screenthing($self);

    $self->lines_to_spans();

    return $self if $self->hooks->{leave_spans};

    $self->spans_to_jquery();

    # get in there and sprinkle spans by the tens over many jquery.appends
    # start $('selector').append('(<span.+</span>)+');
    if (length($self->jquery) > 3000) {
        my ($start, $spannage, $end) = $self->jquery =~
            /^(.+append\(")(.+)("\);)$/sg;
        die "ugh" unless $start && $spannage && $end;
        my @spans = split /(?<=<\/span>)/, $spannage;
        while (@spans) {
            my @chunks;
            push @chunks, grep { defined } shift @spans for 1..10;
            my $middle = join "", @chunks;
            $self->hostinfo->send("$start $middle $end");
        }
    }
    else {
        $self->hostinfo->send($self->jquery."\n") unless $self->hooks->{notx};
    }
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
sub spans_to_htmls {
    my $self = shift;
    my $add = shift;
    my @htmls;
    $self->{hooks}->{catch_span_htmls} = sub {
        shift; push @htmls, @_;
    };
    $self->{hooks}->{spans_to_jquery} = sub {
        my $self = shift;
        for my $s (@{$self->spans}) {
            $s->{top} += $add->{top};
            $s->{left} += $add->{left}
        }
    };
    $self->spans_to_jquery();
    return @htmls;
}
sub spans_to_jquery {
    my $self = shift;
    if ($self->{hooks}->{spans_to_jquery}) {
        $self->{hooks}->{spans_to_jquery}->($self);
    }
    my $spans = $self->spans;
    my $viewid = $self->view;
    my $top_add = 0;
    my @span_htmls;
    for my $s (@$spans) {
        my $mid = { %$s };
        my $value = delete($mid->{value});
        my $p = dclone $mid;
        $p->{style} = join "; ", grep /\S/, 
            (exists $p->{top} ? "top: ".delete($p->{top})."px" : ''),
            (exists $p->{left} ? "left: ".delete($p->{left})."px" : ''),
            (exists $p->{right} ? "right: ".delete($p->{right})."px" : ''),
            ($p->{style} ? delete($p->{style}) : '');
        my $attrstring = join " ", map {
            $_.'="'.$p->{$_}.'"' } sort keys %$p;

        my $span_html;
        if ($value =~ /<span/) {
            $span_html = $value;
        }
        if (ref $value eq "Texty") {
            $p->{style} .= "border: 1px solid pink;";
            say "Doing this thing now";
            my @htmls = $value->spans_to_htmls($p);
            $value = join" ", @htmls;
            $span_html = "<span $attrstring></span>$value";
        }
        else {
            $value = encode_entities($value);
            $span_html = "<span $attrstring>$value</span>";
        }
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

    $self->owner->event($tx, $event, $self);
}

1;
