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

    $self->wipehtml();

    $self;
}

# right so here we have an arc of stuff, going from motive to static
# menu items to text
# here's a travel too, that's kind of a mirage.

sub label {
    my $self = shift;
    $self->{label} = 1;
    $self;
}

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
    
    $self->{travel} ||= Travel->new($self->hostinfo->intro, $self);

    if (@_) {
        return $self->{travel}->travel([@_]);
    }
    return $self->{travel};
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
    my $blank = $self->{label} ? ('<span class="'.$self->{id}
        .'" style="top 1px; position relative; right: 1px; align: right;">'
        .$self->{divid}.'</span>') : "";
    $self->html($blank);
    $self->hostinfo->send("\$('#".$self->{divid}." > .".$self->{id}."').remove()");
    1;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $this = shift;

    say "Event in $self->{id} heading for ".$self->owner;

    $self->owner->event($tx, $event, $this, $self);
}

sub takeover {
    my $self = shift;
    my $html = concat_array(shift); # [([html+],html)+]
    my $append = shift;
    my $tempness;

    if ($append) {
        if ($append eq "temp") {
            my $tempid = $self->{id}."-temp";
            $self->hostinfo->send( # create a -temp span container
                "\$('#".$self->{divid}."').append('<span style=\"display: none;\" id=\"$tempid\"></span>');"
            );
            $self->hostinfo->send( # chuck old stuff in there
                "\$('#".$self->{divid}." .".$self->{id}."').appendTo('#$tempid');"
            );
            $self->wipehtml;
            $tempness = { tempid => $tempid };
        }
        else {
            $self->html($self->html."   ".$html);
        }
    }
    else {
        $self->wipehtml;
        $self->html($html);
    }

    $self->hostinfo->view_incharge($self);

    $self->part_and_append($self->{divid} => $html);

    return $tempness;
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
        die "this is probably fucked";
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

sub concat_array {
    my $a = shift;
    if (ref \$a eq "SCALAR") {
        return $a;
    }
    else {
        return join "", map { concat_array($_) } @$a;
    }
}

1;
