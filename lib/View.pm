package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;

has 'hostinfo';
has 'owner';
has 'divid';
has 'id';
has 'others';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->owner(shift);
    $self->divid(shift);
    $self->hostinfo->screenthing($self);
    $self->others(shift);

    $self;
}

# plugin for "And: $self->id"
# args: lines, hooks
sub text {
    my $self = shift;

    $self->{text} ||= Texty->new($self->hostinfo->intro, $self, @_);
}
sub kill {
    my $self = shift;
    $self->wipehtml;
}

sub wipehtml {
    my $self = shift;
    $self->hostinfo->send("\$('.".$self->id."').remove()");
}

sub takeover {
    my $self = shift;
    my $htmls = shift;
    my $append = shift;
    
    # other views .id set hidden
    $self->hostinfo->send(
        "\$('#".$self->divid." span').hide();" # others
       ." \$('.".$self->id."').show();" # us
       .($append ? "" : "\$('.".$self->id."').remove()")
    );

    $self->wipehtml unless $append;
    
    my $divid = $self->divid;
    my $html;
    for my $h (@$htmls) {
        if (ref $h eq "ARRAY") {
            use Carp;
            confess "bullshit!".anydump($h);
        }
        $html .= $h;
    }

    $self->part_and_append($divid => $html);
}

sub part_and_append {
    my $self = shift;
    my $divid = shift;
    my $html = shift;

    return say "no html" unless $html;
    
    if (length($html) > 30000) {
        my @htmls = split /(?<=<\/span>)\s*(?=<span)/, $html;

        
        my @html_batches;
        my $b = [];
        for my $html (@htmls) {
            push @$b, $html;
            if (@$b > 10) {
                push @html_batches, [ @$b ];
                $b = [];
            }
        }
        push @html_batches, [ @$b ] if @$b;
        say "Think we've batchified htmls: ". anydump(\@html_batches);

        for my $html_batch (@html_batches) {

            my $html = join "", @$html_batch;

            $html =~ s/'/\\'/;
            $self->hostinfo->send("  \$('#$divid').append('$html');");

        }
    }
    else {
        $html =~ s/'/\\'/;
        $self->hostinfo->send("  \$('#$divid').append('$html');");
    }
}

1;
