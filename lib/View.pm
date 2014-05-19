package View;
use Mojo::Base 'Mojolicious::Controller';
use Scriptalicious;
use Texty;
use Time::HiRes 'usleep';

has 'hostinfo';
has 'owner';
has 'divid';
has 'id';

sub new {
    my $self = bless {}, shift;
    shift->($self);

    my $divid = $self->{divid} = shift;
    
    $self;
}

# right so here we have an arc of stuff, going from motive to static
# menu items to text
# here's a travel too, that's kind of a mirage.

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

# Tractorise this thing, watch it
sub flooz {
    my $self = shift;
    my $what = shift;

    if (!$self->{floozal}) {
        die "not floozal: ".$self->label;
    }

    $self->{hostinfo}->flood($what => $self);
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

sub label {
    my $self = shift;
    return "$self->owner $self->{divid}".($self->{extra_label} ? "<br/>$self->{extra_label}" : "");
}

sub default_html {
    my $self = shift;
    my $html = "";
    if ($self->{floozal}) {
        $html .= '<span class="'.$self->{id}
            .'" style="top 1px; position: relative; right: 1px; align: right;">'
            .$self->label.'</span>';
    }
    return $html;
}

sub html {
    my $self = shift;
    my $html = shift;
    if (defined $html) {
        $self->{html} = $self->default_html().$html;
    }
    else {
        $self->{html};
    }
}

sub wipehtml {
    my $self = shift;
    $self->hostinfo->send("\$('#".$self->{divid}." > .".$self->{id}."').remove();") if $self->html;
    $self->html("");
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

    if (!defined $html) {
        say " $self->{divid} reload,";
        $html = $self->html;
    }
    elsif ($append) {
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

    $self->append_spans($self->{divid} => $html);

    return $tempness;
}

sub append_spans {
    my $self = shift;
    my $divid = shift;
    my $html = shift;

    return say "\n\nno html\n\n" unless $html;

    if (length($html) < 30000) {
        $html =~ s/'/\\'/;
        $self->hostinfo->send("  \$('#$divid').append('$html');");
    }
    else {
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
