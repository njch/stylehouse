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
    
    # make leaving here default?
    return $self if $self->hooks->{leave_spans};

    $self->spans_to_jquery();

    $self->send_jquery();
    return $self;
}

sub send_jquery {
    my $self = shift;
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
}

sub lines_to_spans {
    my $self = shift;
    my $es = $self->lines;
    my $id = $self->id;
    my @spans;
    my $l = 0;
    for my $value (@$es) {
        my $span = {
            class => "data",
            id => ($id.'-'.$l++),
        };

        if ($value =~ /<span/) {
            # TODO where what how
            $span->{value} = $value;
        }
        if (ref $value eq "Texty") {
            $span->{style} .= "border: 1px solid pink;";
            my @inners = @{ $value->spans };
            $_->{left} += 20 for @inners;
            push @spans, @inners;
        }
        else {
            $value = encode_entities($value);
        }

        push @spans, {
            class => "data",
            id => ($id.'-'.$l++),
            value => $value,
        };
    }

    $self->spans([@spans]);

    $self->spatialise();
}
sub spatialise {
    my $self = shift;
    my $geo = shift || { top => 30, left => 20 };
    for my $s (@{$self->spans}) {
        $s->{top} ||= 0;
        $s->{top} = $geo->{top};
        $s->{left} ||= 0;
        $s->{left} += $geo->{left};
        $geo->{top} += 20;
    }
}

sub spans_to_htmls {
    my $self = shift;
    my $add = shift;
    my $owner = shift;
    my @htmls;
    $self->{hooks}->{catch_span_htmls} = sub {
        shift; push @htmls, @_;
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

    $self->owner->event($tx, $event, $self);
}

1;
