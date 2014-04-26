package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'hostinfo';
has 'owner';
has 'divid';
has 'id';
has 'html';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    $self->html("");

    $self;
}

sub onunfocus {
    my $self = shift;
    my $sub = shift;
    $self->{onunfocus} = $sub;
    return $self;
}

sub unfocus {
    my $self = shift;
    if ($self->{onunfocus}) {
        $self->{onunfocus}->();
    }
    if ($self->{menu}) {
        # our menu span ids will be like text but -menu so the texty takeover will not rm it
    }
    # could hide our spans? the above hook from Codo to code_unfocus does that
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

sub menu {
    my $self = shift;

    $self->{menu} ||= Menu->new($self->hostinfo->intro, $self, @_);
}

sub travel {
    my $self = shift;
    
    $self->{travel} ||= Travel->new($self->hostinfo->intro, $self->id);

    $self->{travel}->travel(@_);
}

sub nah {
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
    $self->html("");
    $self->hostinfo->send("\$('.".$self->id."').remove()");
    1;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $this = shift;

    say "Event in $self heading for ".$self->owner;

    $self->owner->event($tx, $event, $this, $self);
}

sub takeover {
    my $self = shift;
    my $htmls = shift;
    my $append = shift;
    my $divid = $self->divid;
    my $html;
    for my $h (@$htmls) {
        if (ref $h eq "ARRAY") {
            $h = @$h;
        }
        $html .= $h;
    }
    
    # other views .id set hidden
    #$self->hostinfo->send(
    #    "\$('#".$self->divid." span').hide();" # others # TODO add in exception for constant stuff
    #   ." \$('.".$self->id."').show();" # us
    #   .($append ? "" : "\$('.".$self->id."').remove()")
    #) unless $self->divid eq "menu";

    $append ?
        $self->html($self->html."\n".$html)
      : $self->wipehtml && $self->html($html);
    

    $self->hostinfo->view_incharge($self);

    $self->part_and_append($divid => $html);
}

sub review {
    my $self = shift;
    
    $self->part_and_append($self->divid => $self->html);
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
        say anydump($html_batches[0]->[0]);
        say anydump($html_batches[1]->[0]);
        say "batchified htmls heading for #$divid from ".$self->owner.": ".(scalar(@html_batches)-1)." x 10 + ".scalar(@{$html_batches[-1]});

        for my $html_batch (@html_batches) {

            my $batch = join "", @$html_batch;

            $batch =~ s/'/\\'/;
            $self->hostinfo->send("  \$('#$divid').append('$batch');");
            usleep 10000;
        }
    }
    else {
        $html =~ s/'/\\'/;
        $self->hostinfo->send("  \$('#$divid').append('$html');");
    }
}

1;
