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

# the tab is the repositories
# each thing you care about has a certain thing going on you like to keep an eye on
# they are free to change and adapt, join and split
# whatever
# TODO store everything we need on the USER'S DOM so the server doesn't fill up with clutter
# it could work even from a residential internet site...
# you just have to push your content out to hosts as you host it
# it could be a whole lot of websockets free to come and go to a whole lot of stylehousen hosted by google
# plugin for "And: $self->id"
# args: lines, hooks
sub text {
    my $self = shift;

    $self->{text} ||= Texty->new($self->hostinfo->intro, $self, @_);
}

sub kill {
    my $self = shift;
    say "Ref: ".ref $self->owner;
    $self->wipehtml unless ref $self->owner eq "Lyrico";
}

sub resume {
    my $self = shift;
    say "cannot be bothered resuming right now";
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
    #$self->hostinfo->send(
    #    "\$('#".$self->divid." span').hide();" # others # TODO add in exception for constant stuff
    #   ." \$('.".$self->id."').show();" # us
    #   .($append ? "" : "\$('.".$self->id."').remove()")
    #) unless $self->divid eq "menu";

    $self->wipehtml unless $append;
    
    my $divid = $self->divid;
    my $html;
    for my $h (@$htmls) {
        if (ref $h eq "ARRAY") {
            $h = @$h;
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
