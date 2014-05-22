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
sub newtext {
    my $self = shift;
    delete $self->{text};
    $self->text(@_);
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

sub spawn_floozy {
    my $self = shift;
    my $this = shift if ref $_[0];
    my $divid = shift;
    my $style = shift;
    my $attach = shift;
    my $where = shift;

    if (!$attach && !$where) {
        if ($self->{ceiling}) {
            $attach = "after";
            $where = $self->{ceiling};
        }
        else {
            if ($self->{hostinfo}->get("floods/$self->{divid}")) {
                $attach = "before";
                $where = "#$self->{divid} *:first";
            }
            else {
                $attach = "append";
                $where = $self;
            }
        }
    }

    $where = "#$where->{divid}" if ref $where;

    say "Spawning floozy $divid   : $style";
    say "    $attach => $where";

    my $floozy = $self->{hostinfo}->create_view(
        ($this || $self), $divid, $style,
        $attach => $where,
    );

    $self->{hostinfo}->accum("floods/$self->{divid}", $floozy);
    $floozy->{floozal} = 1;

    $floozy;
}

sub spawn_ceiling {
    my $self = shift;
    my $style = shift;
    my $staticness = shift;
    
    $style .= " position: fixed;" if $staticness;

    my $c = $self->{ceiling} = $self->spawn_floozy($self, $self->{divid}."_ceiling", $style);

    if ($staticness) {
        $c->spawn_floon();
    }

    $c
}

sub spawn_floon { # floozy becomes fixed to a space above the floozal cortex
    my $self = shift;

    my $style = $self->{hostinfo}->get('tvs/'.$self->{divid}.'/style');
    my ($height) = $style =~ /(height:.+?;)/;
    my ($width) = $style =~ /(width:.+?;)/;
    $style = "$height $width opacity:0.1;";

    $self->{floon} = $self->spawn_floozy($self, $self->{divid}."_floon", $style, before => $self);
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
    say "View removing ".$self->label;
    $self->hostinfo->send("\$('#$self->{divid}').remove();");
    $self->wipehtml unless ref $self->owner eq "Lyrico";
}

sub resume {
    my $self = shift;
    say "cannot be bothered resuming right now";
}

sub label {
    my $self = shift;
    return "$self->{owner} $self->{divid}".($self->{extra_label} ? "<br/>$self->{extra_label}" : "");
}

sub default_html {
    my $self = shift;
    my $html = "";
    if ($self->{floozal}) {
        $html .= '<span class="'.$self->{id}
            .'" style="top 1px; position: fixed; right: 1px; align: right;">'
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
    $self->hostinfo->send("\$('#".$self->{divid}." > *').remove();") if $self->html;
    $self->fit_div();
    $self->html("");
    1;
}

sub event {
    my $self = shift;
    my $tx = shift;
    my $event = shift;
    my $this = shift;

    say "Event in ".$self->label." heading for "
        .$self->owner.($self->{owner}->{name} ? " ($self->{owner}->{name})" : "");

    $self->owner->event($tx, $event, $this, $self);
}

sub takeover {
    my $self = shift;
    my $html = concat_array(shift); # [([html+],html)+]
    my $texty = shift;

    if (!defined $html) {
        say " $self->{divid} reload,";
        $html = $self->html;
    }
    elsif ($texty->{hooks}->{append}) {
        $self->html($self->html."   ".$html);
    }
    else {
        $self->wipehtml;
        $self->html($html);
    }

    $self->hostinfo->view_incharge($self);

    $self->append_spans($self->{divid} => $html);
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

    $self->fit_div();
}

sub fit_div {
    my $self = shift;
    my $texty = $self->{text} || $self->{menu}->{text} || return;
    $texty->fit_div();
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
